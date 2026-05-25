import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString, MinLength } from 'class-validator';

export class ResetPasswordDto {
  @ApiProperty({ description: 'Access token from the password reset email link' })
  @IsString()
  @IsNotEmpty()
  accessToken: string;

  @ApiProperty({ example: 'NewStrongPass123', minLength: 8 })
  @IsString()
  @MinLength(8)
  newPassword: string;
}
