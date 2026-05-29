import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { randomUUID } from 'crypto';
import { mkdir, writeFile } from 'fs/promises';
import { extname, join } from 'path';

export type UploadedMediaFile = {
  originalname: string;
  buffer: Buffer;
};

@Injectable()
export class UploadService {
  private readonly uploadDir = join(process.cwd(), 'uploads');

  constructor(private readonly config: ConfigService) {}

  async saveFile(file: UploadedMediaFile): Promise<string> {
    await mkdir(this.uploadDir, { recursive: true });
    const ext = extname(file.originalname) || '.bin';
    const filename = `${randomUUID()}${ext}`;
    await writeFile(join(this.uploadDir, filename), file.buffer);
    const base =
      this.config.get<string>('API_PUBLIC_URL') ?? 'http://localhost:3000';
    return `${base}/uploads/${filename}`;
  }
}
