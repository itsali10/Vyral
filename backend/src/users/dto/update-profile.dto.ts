import { ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsBoolean,
  IsOptional,
  IsString,
  IsUrl,
  Matches,
  MaxLength,
  MinLength,
} from 'class-validator';

export class UpdateProfileDto {
  @ApiPropertyOptional({ example: 'ali_osama' })
  @IsOptional()
  @IsString()
  @MinLength(3)
  @MaxLength(20)
  @Matches(/^[a-zA-Z0-9_.]+$/, {
    message: 'Username may only contain letters, numbers, dots, and underscores',
  })
  username?: string;

  @ApiPropertyOptional({ example: 'Ali Osama' })
  @IsOptional()
  @IsString()
  fullName?: string;

  @ApiPropertyOptional({ example: 'Flutter dev & content creator', maxLength: 150 })
  @IsOptional()
  @IsString()
  @MaxLength(150)
  bio?: string;

  @ApiPropertyOptional({ description: 'URL of uploaded avatar image' })
  @IsOptional()
  @IsString()
  avatarUrl?: string;

  @ApiPropertyOptional({ example: 'https://mysite.com' })
  @IsOptional()
  @IsUrl()
  websiteUrl?: string;

  @ApiPropertyOptional({ example: 'he/him' })
  @IsOptional()
  @IsString()
  @MaxLength(40)
  pronouns?: string;

  @ApiPropertyOptional({ example: false })
  @IsOptional()
  @IsBoolean()
  isPrivate?: boolean;
}
