import {
  IsNotEmpty,
  IsString,
  IsOptional,
  IsUUID,
  IsNumber,
  IsPositive,
} from 'class-validator';

export class CreateTrackDto {
  @IsNotEmpty()
  @IsString()
  name: string;

  @IsOptional()
  @IsUUID(4)
  artistId: string | null;

  @IsOptional()
  @IsUUID(4)
  albumId: string | null;

  @IsNumber()
  @IsPositive()
  duration: number;
}
