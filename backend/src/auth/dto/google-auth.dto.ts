import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString } from 'class-validator';

export class GoogleAuthDto {
  @ApiProperty({ description: 'Google ID token obtained from Flutter Google Sign-In' })
  @IsString()
  @IsNotEmpty()
  idToken: string;
}
