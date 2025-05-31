import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { Artist } from '../types';
import { CreateArtistDto } from '../dto/create-artist.dto';
import { UpdateArtistDto } from '../dto/update-artist.dto';
import { randomUUID } from 'crypto';
import { CleanupService } from '../shared/cleanup.service';

@Injectable()
export class ArtistService {
  private artists: Artist[] = [];

  constructor(private readonly cleanupService: CleanupService) {}

  private isValidUUID(id: string): boolean {
    const uuidRegex =
      /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
    return uuidRegex.test(id);
  }

  findAll(): Artist[] {
    return this.artists;
  }

  findOne(id: string): Artist {
    if (!this.isValidUUID(id)) {
      throw new BadRequestException('Invalid artist ID');
    }

    const artist = this.artists.find((artist) => artist.id === id);
    if (!artist) {
      throw new NotFoundException('Artist not found');
    }

    return artist;
  }

  create(createArtistDto: CreateArtistDto): Artist {
    const newArtist: Artist = {
      id: randomUUID(),
      name: createArtistDto.name,
      grammy: createArtistDto.grammy,
    };

    this.artists.push(newArtist);
    return newArtist;
  }

  update(id: string, updateArtistDto: UpdateArtistDto): Artist {
    if (!this.isValidUUID(id)) {
      throw new BadRequestException('Invalid artist ID');
    }

    const artist = this.artists.find((artist) => artist.id === id);
    if (!artist) {
      throw new NotFoundException('Artist not found');
    }

    if (updateArtistDto.name !== undefined) {
      artist.name = updateArtistDto.name;
    }
    if (updateArtistDto.grammy !== undefined) {
      artist.grammy = updateArtistDto.grammy;
    }

    return artist;
  }

  remove(id: string): void {
    if (!this.isValidUUID(id)) {
      throw new BadRequestException('Invalid artist ID');
    }

    const index = this.artists.findIndex((artist) => artist.id === id);
    if (index === -1) {
      throw new NotFoundException('Artist not found');
    }

    this.artists.splice(index, 1);
    this.cleanupService.performCleanup('artist', id);
  }

  exists(id: string): boolean {
    return this.artists.some((artist) => artist.id === id);
  }
}
