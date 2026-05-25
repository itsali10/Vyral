import { ApiProperty } from '@nestjs/swagger';
import {
  IsEmail,
  IsNotEmpty,
  IsString,
  Matches,
  MaxLength,
  MinLength,
} from 'class-validator';

export class RegisterDto {
  @ApiProperty({ example: 'Ali Osama' })
  @IsString()
  @IsNotEmpty()
  fullName: string;

  @ApiProperty({ example: 'ali_osama' })
  @IsString()
  @MinLength(3)
  @MaxLength(20)
  @Matches(/^[a-zA-Z0-9_.]+$/, {
    message: 'Username may only contain letters, numbers, dots, and underscores',
  })
  username: string;

  @ApiProperty({ example: 'ali@example.com' })
  @IsEmail()
  email: string;

  @ApiProperty({ example: 'StrongPass123', minLength: 8 })
  @IsString()
  @MinLength(8)
  password: string;
}
