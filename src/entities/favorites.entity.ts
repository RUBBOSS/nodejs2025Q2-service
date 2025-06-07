import { Entity, PrimaryGeneratedColumn, Column, ManyToMany, JoinTable } from 'typeorm';
import { Artist } from './artist.entity';
import { Album } from './album.entity';
import { Track } from './track.entity';

@Entity('favorites')
export class Favorites {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToMany(() => Artist)
  @JoinTable({
    name: 'favorite_artists',
    joinColumn: { name: 'favoritesId', referencedColumnName: 'id' },
    inverseJoinColumn: { name: 'artistId', referencedColumnName: 'id' }
  })
  artists: Artist[];

  @ManyToMany(() => Album)
  @JoinTable({
    name: 'favorite_albums',
    joinColumn: { name: 'favoritesId', referencedColumnName: 'id' },
    inverseJoinColumn: { name: 'albumId', referencedColumnName: 'id' }
  })
  albums: Album[];

  @ManyToMany(() => Track)
  @JoinTable({
    name: 'favorite_tracks',
    joinColumn: { name: 'favoritesId', referencedColumnName: 'id' },
    inverseJoinColumn: { name: 'trackId', referencedColumnName: 'id' }
  })
  tracks: Track[];
}
