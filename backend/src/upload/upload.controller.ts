import {
  BadRequestException,
  Controller,
  Post,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import {
  ApiBearerAuth,
  ApiConsumes,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import { AuthGuard } from '../common/guards/auth.guard';
import { UploadService } from './upload.service';
import type { UploadedMediaFile } from './upload.service';

@ApiTags('Upload')
@ApiBearerAuth('access-token')
@UseGuards(AuthGuard)
@Controller('upload')
export class UploadController {
  constructor(private readonly uploadService: UploadService) {}

  @Post()
  @ApiOperation({
    summary: 'Upload image or video to Supabase Storage; returns public URL',
  })
  @ApiConsumes('multipart/form-data')
  @UseInterceptors(
    FileInterceptor('file', {
      limits: { fileSize: 15 * 1024 * 1024 },
    }),
  )
  async upload(@UploadedFile() file: UploadedMediaFile) {
    if (!file || !file.buffer?.length) {
      throw new BadRequestException(
        'No image file received. Send multipart field "file".',
      );
    }
    const url = await this.uploadService.saveFile(file);
    return { url };
  }
}
