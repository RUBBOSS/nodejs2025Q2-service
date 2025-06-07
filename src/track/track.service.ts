import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Track } from '../entities/track.entity';
import { CreateTrackDto } from '../dto/create-track.dto';
import { UpdateTrackDto } from '../dto/update-track.dto';
import { CleanupService } from '../shared/cleanup.service';

@Injectable()
export class TrackService {
  constructor(
    @InjectRepository(Track)
    private trackRepository: Repository<Track>,
    private readonly cleanupService: CleanupService,
  ) {
    this.cleanupService.registerCleanupCallback('artist', (id: string) =>
      this.updateTracksOnArtistDelete(id),
    );
    this.cleanupService.registerCleanupCallback('album', (id: string) =>
      this.updateTracksOnAlbumDelete(id),
    );
  }

  private isValidUUID(id: string): boolean {
    const uuidRegex =
      /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
    return uuidRegex.test(id);
  }

  async findAll(): Promise<Track[]> {
    return await this.trackRepository.find();
  }

  async findOne(id: string): Promise<Track> {
    if (!this.isValidUUID(id)) {
      throw new BadRequestException('Invalid track ID');
    }

    const track = await this.trackRepository.findOne({ where: { id } });
    if (!track) {
      throw new NotFoundException('Track not found');
    }

    return track;
  }

  async create(createTrackDto: CreateTrackDto): Promise<Track> {
    const newTrack = this.trackRepository.create({
      name: createTrackDto.name,
      artistId: createTrackDto.artistId,
      albumId: createTrackDto.albumId,
      duration: createTrackDto.duration,
    });

    return await this.trackRepository.save(newTrack);
  }

  async update(id: string, updateTrackDto: UpdateTrackDto): Promise<Track> {
    if (!this.isValidUUID(id)) {
      throw new BadRequestException('Invalid track ID');
    }

    const track = await this.trackRepository.findOne({ where: { id } });
    if (!track) {
      throw new NotFoundException('Track not found');
    }

    if (updateTrackDto.name !== undefined) {
      track.name = updateTrackDto.name;
    }
    if (updateTrackDto.artistId !== undefined) {
      track.artistId = updateTrackDto.artistId;
    }
    if (updateTrackDto.albumId !== undefined) {
      track.albumId = updateTrackDto.albumId;
    }
    if (updateTrackDto.duration !== undefined) {
      track.duration = updateTrackDto.duration;
    }

    return await this.trackRepository.save(track);
  }

  async remove(id: string): Promise<void> {
    if (!this.isValidUUID(id)) {
      throw new BadRequestException('Invalid track ID');
    }

    const result = await this.trackRepository.delete(id);
    if (result.affected === 0) {
      throw new NotFoundException('Track not found');
    }

    this.cleanupService.performCleanup('track', id);
  }

  async updateTracksOnArtistDelete(artistId: string): Promise<void> {
    await this.trackRepository.update({ artistId }, { artistId: null });
  }

  async updateTracksOnAlbumDelete(albumId: string): Promise<void> {
    await this.trackRepository.update({ albumId }, { albumId: null });
  }
}
