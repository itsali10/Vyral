import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsArray, IsOptional, IsString } from 'class-validator';

export class UpdatePostDto {
  @ApiPropertyOptional({ example: 'Updated caption ✨' })
  @IsOptional()
  @IsString()
  caption?: string;

  @ApiPropertyOptional({ type: [String], example: ['updated', 'hashtag'] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  hashtags?: string[];

  @ApiPropertyOptional({ example: 'Alexandria, Egypt' })
  @IsOptional()
  @IsString()
  location?: string;
}
