import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Album } from '../entities/album.entity';
import { CreateAlbumDto } from '../dto/create-album.dto';
import { UpdateAlbumDto } from '../dto/update-album.dto';
import { CleanupService } from '../shared/cleanup.service';

@Injectable()
export class AlbumService {
  constructor(
    @InjectRepository(Album)
    private albumRepository: Repository<Album>,
    private readonly cleanupService: CleanupService,
  ) {
    this.cleanupService.registerCleanupCallback('artist', (id: string) =>
      this.updateAlbumsOnArtistDelete(id),
    );
  }

  private isValidUUID(id: string): boolean {
    const uuidRegex =
      /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
    return uuidRegex.test(id);
  }

  async findAll(): Promise<Album[]> {
    return await this.albumRepository.find();
  }

  async findOne(id: string): Promise<Album> {
    if (!this.isValidUUID(id)) {
      throw new BadRequestException('Invalid album ID');
    }

    const album = await this.albumRepository.findOne({ where: { id } });
    if (!album) {
      throw new NotFoundException('Album not found');
    }

    return album;
  }

  async create(createAlbumDto: CreateAlbumDto): Promise<Album> {
    const newAlbum = this.albumRepository.create({
      name: createAlbumDto.name,
      year: createAlbumDto.year,
      artistId: createAlbumDto.artistId,
    });

    return await this.albumRepository.save(newAlbum);
  }

  async update(id: string, updateAlbumDto: UpdateAlbumDto): Promise<Album> {
    if (!this.isValidUUID(id)) {
      throw new BadRequestException('Invalid album ID');
    }

    const album = await this.albumRepository.findOne({ where: { id } });
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

    return await this.albumRepository.save(album);
  }

  async remove(id: string): Promise<void> {
    if (!this.isValidUUID(id)) {
      throw new BadRequestException('Invalid album ID');
    }

    const result = await this.albumRepository.delete(id);
    if (result.affected === 0) {
      throw new NotFoundException('Album not found');
    }

    this.cleanupService.performCleanup('album', id);
  }

  async updateAlbumsOnArtistDelete(artistId: string): Promise<void> {
    await this.albumRepository.update({ artistId }, { artistId: null });
  }
}
