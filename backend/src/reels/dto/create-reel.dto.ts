import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsArray,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  Max,
  Min,
} from 'class-validator';

export class CreateReelDto {
  @ApiProperty({ description: 'URL of the uploaded video' })
  @IsString()
  @IsNotEmpty()
  videoUrl: string;

  @ApiPropertyOptional({ example: 'Check this out 🔥 #viral' })
  @IsOptional()
  @IsString()
  caption?: string;

  @ApiPropertyOptional({ description: 'Audio track name or URL' })
  @IsOptional()
  @IsString()
  audioTrack?: string;

  @ApiProperty({ description: 'Duration in seconds (max 90)', example: 30 })
  @IsNumber()
  @Min(1)
  @Max(90)
  duration: number;

  @ApiPropertyOptional({ type: [String], example: ['viral', 'trending'] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  hashtags?: string[];
}
