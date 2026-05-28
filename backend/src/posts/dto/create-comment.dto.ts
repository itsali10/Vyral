import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString, MaxLength } from 'class-validator';

export class CreateCommentDto {
  @ApiProperty({ example: 'Love this!' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(500)
  text: string;
}
