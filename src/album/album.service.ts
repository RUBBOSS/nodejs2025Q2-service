import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { Album } from '../types';
import { CreateAlbumDto } from '../dto/create-album.dto';
import { UpdateAlbumDto } from '../dto/update-album.dto';
import { randomUUID } from 'crypto';

@Injectable()
export class AlbumService {
  private albums: Album[] = [];

  private isValidUUID(id: string): boolean {
    const uuidRegex =
      /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
    return uuidRegex.test(id);
  }

  findAll(): Album[] {
    return this.albums;
  }

  findOne(id: string): Album {
    if (!this.isValidUUID(id)) {
      throw new BadRequestException('Invalid album ID');
    }

    const album = this.albums.find((album) => album.id === id);
    if (!album) {
      throw new NotFoundException('Album not found');
    }

    return album;
  }

  create(createAlbumDto: CreateAlbumDto): Album {
    const newAlbum: Album = {
      id: randomUUID(),
      name: createAlbumDto.name,
      year: createAlbumDto.year,
      artistId: createAlbumDto.artistId,
    };

    this.albums.push(newAlbum);
    return newAlbum;
  }

  update(id: string, updateAlbumDto: UpdateAlbumDto): Album {
    if (!this.isValidUUID(id)) {
      throw new BadRequestException('Invalid album ID');
    }

    const album = this.albums.find((album) => album.id === id);
    if (!album) {
      throw new NotFoundException('Album not found');
    }

    if (updateAlbumDto.name !== undefined) {
      album.name = updateAlbumDto.name;
    }
    if (updateAlbumDto.year !== undefined) {
      album.year = updateAlbumDto.year;
    }
    if (updateAlbumDto.artistId !== undefined) {
      album.artistId = updateAlbumDto.artistId;
    }

    return album;
  }

  remove(id: string): void {
    if (!this.isValidUUID(id)) {
      throw new BadRequestException('Invalid album ID');
    }

    const index = this.albums.findIndex((album) => album.id === id);
    if (index === -1) {
      throw new NotFoundException('Album not found');
    }

    this.albums.splice(index, 1);
  }

  updateAlbumsOnArtistDelete(artistId: string): void {
    this.albums.forEach((album) => {
      if (album.artistId === artistId) {
        album.artistId = null;
      }
    });
  }
}
