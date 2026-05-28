import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString, MaxLength } from 'class-validator';

export class CreateCollectionDto {
  @ApiProperty({ example: 'Soft mornings' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(80)
  name: string;
}
