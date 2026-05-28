import { ApiPropertyOptional } from '@nestjs/swagger';
import {
  ArrayMaxSize,
  IsArray,
  IsBoolean,
  IsIn,
  IsOptional,
  IsString,
  MaxLength,
} from 'class-validator';

export class UpdateSettingsDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  showLikesPublicly?: boolean;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  notifLikes?: boolean;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  notifComments?: boolean;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  notifFollowers?: boolean;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  notifTrending?: boolean;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  dataSaver?: boolean;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  hapticsEnabled?: boolean;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  exploreGridCompact?: boolean;

  @ApiPropertyOptional({ enum: ['rose', 'teal', 'purple', 'amber'] })
  @IsOptional()
  @IsString()
  @IsIn(['rose', 'teal', 'purple', 'amber'])
  accentColor?: string;

  @ApiPropertyOptional({ enum: ['for_you', 'following', 'trending'] })
  @IsOptional()
  @IsString()
  @IsIn(['for_you', 'following', 'trending'])
  defaultFeedTab?: string;

  @ApiPropertyOptional({ type: [String], maxItems: 50 })
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(50)
  @IsString({ each: true })
  @MaxLength(40, { each: true })
  mutedWords?: string[];
}
