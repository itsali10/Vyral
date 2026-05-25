import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsNotEmpty, IsOptional, IsString } from 'class-validator';

export class CreateStoryDto {
  @ApiProperty({ description: 'URL of the uploaded story media (image or short video)' })
  @IsString()
  @IsNotEmpty()
  mediaUrl: string;

  @ApiPropertyOptional({ example: 'Good morning! ☀️' })
  @IsOptional()
  @IsString()
  caption?: string;
}
