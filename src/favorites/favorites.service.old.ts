import {
  Injectable,
  NotFoundException,
  BadRequestException,
  UnprocessableEntityException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Favorites } from '../entities/favorites.entity';
import { Artist } from '../entities/artist.entity';
import { Album } from '../entities/album.entity';
import { Track } from '../entities/track.entity';
import { FavoritesResponse } from '../types';
import { ArtistService } from '../artist/artist.service';
import { AlbumService } from '../album/album.service';
import { TrackService } from '../track/track.service';
import { CleanupService } from '../shared/cleanup.service';

@Injectable()
export class FavoritesService {
  private readonly GLOBAL_FAVORITES_ID = 'global-favorites';

  constructor(
    @InjectRepository(Favorites)
    private favoritesRepository: Repository<Favorites>,
    @InjectRepository(Artist)
    private artistRepository: Repository<Artist>,
    @InjectRepository(Album)
    private albumRepository: Repository<Album>,
    @InjectRepository(Track)
    private trackRepository: Repository<Track>,
    private readonly artistService: ArtistService,
    private readonly albumService: AlbumService,
    private readonly trackService: TrackService,
    private readonly cleanupService: CleanupService,
  ) {
    // Register cleanup callbacks
    this.cleanupService.registerCleanupCallback('artist', (id: string) =>
      this.removeArtistFromFavorites(id),
    );
    this.cleanupService.registerCleanupCallback('album', (id: string) =>
      this.removeAlbumFromFavorites(id),
    );
    this.cleanupService.registerCleanupCallback('track', (id: string) =>
      this.removeTrackFromFavorites(id),
    );
  }

  private isValidUUID(id: string): boolean {
    const uuidRegex =
      /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
    return uuidRegex.test(id);
  }

  private async getGlobalFavorites(): Promise<Favorites> {
    let favorites = await this.favoritesRepository.findOne({
      where: { id: this.GLOBAL_FAVORITES_ID },
      relations: ['artists', 'albums', 'tracks'],
    });

    if (!favorites) {
      favorites = this.favoritesRepository.create({
        id: this.GLOBAL_FAVORITES_ID,
        artists: [],
        albums: [],
        tracks: [],
      });
      await this.favoritesRepository.save(favorites);
    }

    return favorites;
  }

  async findAll(): Promise<FavoritesResponse> {
    const favorites = await this.getGlobalFavorites();
    return {
      artists: favorites.artists,
      albums: favorites.albums,
      tracks: favorites.tracks,
    };
  }

  addArtist(id: string): void {
    if (!this.isValidUUID(id)) {
      throw new BadRequestException('Invalid artist ID');
    }

    try {
      this.artistService.findOne(id);
    } catch {
      throw new UnprocessableEntityException('Artist not found');
    }

    if (!this.favorites.artists.includes(id)) {
      this.favorites.artists.push(id);
    }
  }

  removeArtist(id: string): void {
    if (!this.isValidUUID(id)) {
      throw new BadRequestException('Invalid artist ID');
    }

    const index = this.favorites.artists.indexOf(id);
    if (index === -1) {
      throw new NotFoundException('Artist is not in favorites');
    }

    this.favorites.artists.splice(index, 1);
  }

  addAlbum(id: string): void {
    if (!this.isValidUUID(id)) {
      throw new BadRequestException('Invalid album ID');
    }

    try {
      this.albumService.findOne(id);
    } catch {
      throw new UnprocessableEntityException('Album not found');
    }

    if (!this.favorites.albums.includes(id)) {
      this.favorites.albums.push(id);
    }
  }

  removeAlbum(id: string): void {
    if (!this.isValidUUID(id)) {
      throw new BadRequestException('Invalid album ID');
    }

    const index = this.favorites.albums.indexOf(id);
    if (index === -1) {
      throw new NotFoundException('Album is not in favorites');
    }

    this.favorites.albums.splice(index, 1);
  }

  addTrack(id: string): void {
    if (!this.isValidUUID(id)) {
      throw new BadRequestException('Invalid track ID');
    }

    try {
      this.trackService.findOne(id);
    } catch {
      throw new UnprocessableEntityException('Track not found');
    }

    if (!this.favorites.tracks.includes(id)) {
      this.favorites.tracks.push(id);
    }
  }

  removeTrack(id: string): void {
    if (!this.isValidUUID(id)) {
      throw new BadRequestException('Invalid track ID');
    }

    const index = this.favorites.tracks.indexOf(id);
    if (index === -1) {
      throw new NotFoundException('Track is not in favorites');
    }

    this.favorites.tracks.splice(index, 1);
  }

  removeArtistFromFavorites(artistId: string): void {
    const index = this.favorites.artists.indexOf(artistId);
    if (index !== -1) {
      this.favorites.artists.splice(index, 1);
    }
  }

  removeAlbumFromFavorites(albumId: string): void {
    const index = this.favorites.albums.indexOf(albumId);
    if (index !== -1) {
      this.favorites.albums.splice(index, 1);
    }
  }

  removeTrackFromFavorites(trackId: string): void {
    const index = this.favorites.tracks.indexOf(trackId);
    if (index !== -1) {
      this.favorites.tracks.splice(index, 1);
    }
  }
}
