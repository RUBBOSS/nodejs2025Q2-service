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
  private readonly GLOBAL_FAVORITES_ID = '00000000-0000-4000-8000-000000000000';

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

  async addArtist(id: string): Promise<void> {
    if (!this.isValidUUID(id)) {
      throw new BadRequestException('Invalid artist ID');
    }

    try {
      await this.artistService.findOne(id);
    } catch {
      throw new UnprocessableEntityException('Artist not found');
    }

    const favorites = await this.getGlobalFavorites();
    const artist = await this.artistRepository.findOne({ where: { id } });

    if (artist && !favorites.artists.some((a) => a.id === id)) {
      favorites.artists.push(artist);
      await this.favoritesRepository.save(favorites);
    }
  }

  async removeArtist(id: string): Promise<void> {
    if (!this.isValidUUID(id)) {
      throw new BadRequestException('Invalid artist ID');
    }

    const favorites = await this.getGlobalFavorites();
    const artistIndex = favorites.artists.findIndex((a) => a.id === id);

    if (artistIndex === -1) {
      throw new NotFoundException('Artist is not in favorites');
    }

    favorites.artists.splice(artistIndex, 1);
    await this.favoritesRepository.save(favorites);
  }

  async addAlbum(id: string): Promise<void> {
    if (!this.isValidUUID(id)) {
      throw new BadRequestException('Invalid album ID');
    }

    try {
      await this.albumService.findOne(id);
    } catch {
      throw new UnprocessableEntityException('Album not found');
    }

    const favorites = await this.getGlobalFavorites();
    const album = await this.albumRepository.findOne({ where: { id } });

    if (album && !favorites.albums.some((a) => a.id === id)) {
      favorites.albums.push(album);
      await this.favoritesRepository.save(favorites);
    }
  }

  async removeAlbum(id: string): Promise<void> {
    if (!this.isValidUUID(id)) {
      throw new BadRequestException('Invalid album ID');
    }

    const favorites = await this.getGlobalFavorites();
    const albumIndex = favorites.albums.findIndex((a) => a.id === id);

    if (albumIndex === -1) {
      throw new NotFoundException('Album is not in favorites');
    }

    favorites.albums.splice(albumIndex, 1);
    await this.favoritesRepository.save(favorites);
  }

  async addTrack(id: string): Promise<void> {
    if (!this.isValidUUID(id)) {
      throw new BadRequestException('Invalid track ID');
    }

    try {
      await this.trackService.findOne(id);
    } catch {
      throw new UnprocessableEntityException('Track not found');
    }

    const favorites = await this.getGlobalFavorites();
    const track = await this.trackRepository.findOne({ where: { id } });

    if (track && !favorites.tracks.some((t) => t.id === id)) {
      favorites.tracks.push(track);
      await this.favoritesRepository.save(favorites);
    }
  }

  async removeTrack(id: string): Promise<void> {
    if (!this.isValidUUID(id)) {
      throw new BadRequestException('Invalid track ID');
    }

    const favorites = await this.getGlobalFavorites();
    const trackIndex = favorites.tracks.findIndex((t) => t.id === id);

    if (trackIndex === -1) {
      throw new NotFoundException('Track is not in favorites');
    }

    favorites.tracks.splice(trackIndex, 1);
    await this.favoritesRepository.save(favorites);
  }

  async removeArtistFromFavorites(artistId: string): Promise<void> {
    const favorites = await this.getGlobalFavorites();
    const artistIndex = favorites.artists.findIndex((a) => a.id === artistId);

    if (artistIndex !== -1) {
      favorites.artists.splice(artistIndex, 1);
      await this.favoritesRepository.save(favorites);
    }
  }

  async removeAlbumFromFavorites(albumId: string): Promise<void> {
    const favorites = await this.getGlobalFavorites();
    const albumIndex = favorites.albums.findIndex((a) => a.id === albumId);

    if (albumIndex !== -1) {
      favorites.albums.splice(albumIndex, 1);
      await this.favoritesRepository.save(favorites);
    }
  }

  async removeTrackFromFavorites(trackId: string): Promise<void> {
    const favorites = await this.getGlobalFavorites();
    const trackIndex = favorites.tracks.findIndex((t) => t.id === trackId);

    if (trackIndex !== -1) {
      favorites.tracks.splice(trackIndex, 1);
      await this.favoritesRepository.save(favorites);
    }
  }
}
