import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsArray,
  IsEnum,
  IsOptional,
  IsString,
  MaxLength,
} from 'class-validator';
import { PostType } from '../../entities/enums';

export class CreatePostDto {
  @ApiProperty({ enum: PostType, example: PostType.IMAGE })
  @IsEnum(PostType)
  type: PostType;

  @ApiPropertyOptional({ example: 'Sunset vibes 🌅 #golden' })
  @IsOptional()
  @IsString()
  @MaxLength(280)
  caption?: string;

  @ApiPropertyOptional({ type: [String], description: 'Array of media URLs (already uploaded)' })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  mediaUrls?: string[];

  @ApiPropertyOptional({ type: [String], example: ['sunset', 'vibes'] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  hashtags?: string[];

  @ApiPropertyOptional({ example: 'Cairo, Egypt' })
  @IsOptional()
  @IsString()
  location?: string;
}
