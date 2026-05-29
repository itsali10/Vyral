import { BadRequestException } from '@nestjs/common';
import { ValidationError } from 'class-validator';

type ValidationDetail = {
  field: string;
  messages: string[];
};

export function validationExceptionFactory(errors: ValidationError[]) {
  const details = flattenValidationErrors(errors);
  return new BadRequestException({
    message: 'Validation failed',
    error: 'Bad Request',
    details,
  });
}

function flattenValidationErrors(
  errors: ValidationError[],
  parent = '',
): ValidationDetail[] {
  return errors.flatMap((error) => {
    const field = parent ? `${parent}.${error.property}` : error.property;
    const ownMessages = Object.values(error.constraints ?? {});
    const ownDetails =
      ownMessages.length > 0 ? [{ field, messages: ownMessages }] : [];
    const childDetails = flattenValidationErrors(error.children ?? [], field);
    return [...ownDetails, ...childDetails];
  });
}
