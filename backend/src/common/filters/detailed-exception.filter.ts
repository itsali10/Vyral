import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { Request, Response } from 'express';
import { randomUUID } from 'crypto';
import { QueryFailedError } from 'typeorm';

type ErrorDetails = Record<string, unknown> | Array<Record<string, unknown>>;

type ErrorResponseBody = {
  statusCode: number;
  error: string;
  message: string | string[];
  details?: ErrorDetails;
  path: string;
  method: string;
  timestamp: string;
  requestId: string;
};

type HttpExceptionResponse = {
  statusCode?: number;
  error?: string;
  message?: string | string[];
  details?: ErrorDetails;
};

type DatabaseDriverError = {
  code?: string;
  detail?: string;
  constraint?: string;
  table?: string;
  column?: string;
};

@Catch()
export class DetailedExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger(DetailedExceptionFilter.name);

  catch(exception: unknown, host: ArgumentsHost) {
    const context = host.switchToHttp();
    const response = context.getResponse<Response>();
    const request = context.getRequest<Request>();
    const normalized = this.normalizeException(exception);
    const requestId = this.getRequestId(request);

    response.setHeader('x-request-id', requestId);

    if (normalized.statusCode >= HttpStatus.INTERNAL_SERVER_ERROR) {
      this.logger.error(
        `${request.method} ${request.originalUrl} failed (${requestId})`,
        exception instanceof Error ? exception.stack : String(exception),
      );
    }

    const body: ErrorResponseBody = {
      statusCode: normalized.statusCode,
      error: normalized.error,
      message: normalized.message,
      ...(normalized.details ? { details: normalized.details } : {}),
      path: request.originalUrl,
      method: request.method,
      timestamp: new Date().toISOString(),
      requestId,
    };

    response.status(normalized.statusCode).json(body);
  }

  private normalizeException(exception: unknown): {
    statusCode: number;
    error: string;
    message: string | string[];
    details?: ErrorDetails;
  } {
    if (exception instanceof HttpException) {
      const statusCode = exception.getStatus();
      const exceptionResponse = exception.getResponse();
      if (typeof exceptionResponse === 'string') {
        return {
          statusCode,
          error: this.statusText(statusCode),
          message: exceptionResponse,
        };
      }

      const responseBody = exceptionResponse as HttpExceptionResponse;
      return {
        statusCode,
        error: responseBody.error ?? this.statusText(statusCode),
        message: responseBody.message ?? exception.message,
        ...(responseBody.details ? { details: responseBody.details } : {}),
      };
    }

    if (this.isMulterFileSizeError(exception)) {
      return {
        statusCode: HttpStatus.PAYLOAD_TOO_LARGE,
        error: 'Payload Too Large',
        message: 'Uploaded file is too large. Maximum allowed size is 15 MB.',
        details: { limit: '15 MB', field: 'file' },
      };
    }

    if (exception instanceof QueryFailedError) {
      return this.normalizeDatabaseError(exception);
    }

    return {
      statusCode: HttpStatus.INTERNAL_SERVER_ERROR,
      error: 'Internal Server Error',
      message: 'An unexpected server error occurred.',
    };
  }

  private normalizeDatabaseError(error: QueryFailedError) {
    const driverError = error.driverError as DatabaseDriverError | undefined;

    if (driverError?.code === '23505') {
      return {
        statusCode: HttpStatus.CONFLICT,
        error: 'Conflict',
        message: 'A record with this value already exists.',
        details: this.databaseDetails(driverError),
      };
    }

    if (driverError?.code === '23503') {
      return {
        statusCode: HttpStatus.BAD_REQUEST,
        error: 'Bad Request',
        message: 'The request references a record that does not exist.',
        details: this.databaseDetails(driverError),
      };
    }

    if (driverError?.code === '22P02') {
      return {
        statusCode: HttpStatus.BAD_REQUEST,
        error: 'Bad Request',
        message: 'One or more identifiers are invalid.',
        details: this.databaseDetails(driverError),
      };
    }

    return {
      statusCode: HttpStatus.INTERNAL_SERVER_ERROR,
      error: 'Database Error',
      message: 'The database could not complete the request.',
      details: this.databaseDetails(driverError),
    };
  }

  private databaseDetails(driverError?: DatabaseDriverError) {
    return {
      code: driverError?.code ?? 'unknown',
      constraint: driverError?.constraint,
      table: driverError?.table,
      column: driverError?.column,
      detail: driverError?.detail,
    };
  }

  private isMulterFileSizeError(exception: unknown) {
    return (
      typeof exception === 'object' &&
      exception !== null &&
      'code' in exception &&
      (exception as { code?: string }).code === 'LIMIT_FILE_SIZE'
    );
  }

  private getRequestId(request: Request) {
    const incoming = request.header('x-request-id');
    return incoming?.trim() || randomUUID();
  }

  private statusText(statusCode: number) {
    return HttpStatus[statusCode] ?? 'Error';
  }
}
