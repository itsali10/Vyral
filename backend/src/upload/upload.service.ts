import {
  BadRequestException,
  Injectable,
  InternalServerErrorException,
  Logger,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { randomUUID } from 'crypto';
import { extname } from 'path';
import { SupabaseService } from '../supabase/supabase.service';

export type UploadedMediaFile = {
  originalname: string;
  buffer: Buffer;
  mimetype?: string;
};

const ALLOWED_EXTENSIONS = new Set([
  '.jpg',
  '.jpeg',
  '.png',
  '.webp',
  '.gif',
  '.mp4',
  '.webm',
]);

const MIME_BY_EXT: Record<string, string> = {
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.png': 'image/png',
  '.webp': 'image/webp',
  '.gif': 'image/gif',
  '.mp4': 'video/mp4',
  '.webm': 'video/webm',
};

const EXT_BY_MIME: Record<string, string> = {
  'image/jpeg': '.jpg',
  'image/png': '.png',
  'image/webp': '.webp',
  'image/gif': '.gif',
  'video/mp4': '.mp4',
  'video/webm': '.webm',
};

@Injectable()
export class UploadService {
  private readonly logger = new Logger(UploadService.name);
  private readonly bucket: string;

  constructor(
    private readonly config: ConfigService,
    private readonly supabase: SupabaseService,
  ) {
    this.bucket = this.config.get<string>('SUPABASE_STORAGE_BUCKET') ?? 'media';
  }

  async saveFile(file: UploadedMediaFile): Promise<string> {
    const ext = this.resolveExtension(file.originalname, file.mimetype);
    const contentType = this.resolveContentType(ext, file.mimetype);
    const objectPath = `uploads/${randomUUID()}${ext}`;

    const { error } = await this.supabase
      .getAdminClient()
      .storage.from(this.bucket)
      .upload(objectPath, file.buffer, {
        contentType,
        upsert: false,
        cacheControl: '3600',
      });

    if (error) {
      this.logger.error(
        `Supabase storage upload failed (bucket=${this.bucket}): ${error.message}`,
      );
      throw new InternalServerErrorException(
        'Image upload failed. Run backend/scripts/setup-storage.sql in the Supabase SQL editor.',
      );
    }

    const { data } = this.supabase
      .getAdminClient()
      .storage.from(this.bucket)
      .getPublicUrl(objectPath);

    return data.publicUrl;
  }

  private resolveExtension(originalname: string, mimetype?: string): string {
    const ext = extname(originalname).toLowerCase();
    if (ext && ALLOWED_EXTENSIONS.has(ext)) {
      return ext;
    }

    const normalizedMime = mimetype?.split(';')[0]?.trim().toLowerCase();
    if (normalizedMime) {
      const fromMime = EXT_BY_MIME[normalizedMime];
      if (fromMime) {
        return fromMime;
      }
    }

    if (!ext) {
      return '.jpg';
    }

    throw new BadRequestException(
      `Unsupported file type "${ext}". Allowed: ${[...ALLOWED_EXTENSIONS].join(', ')}`,
    );
  }

  private resolveContentType(ext: string, mimetype?: string): string {
    const normalizedMime = mimetype?.split(';')[0]?.trim().toLowerCase();
    if (normalizedMime && EXT_BY_MIME[normalizedMime]) {
      return normalizedMime;
    }
    return MIME_BY_EXT[ext] ?? 'application/octet-stream';
  }
}
