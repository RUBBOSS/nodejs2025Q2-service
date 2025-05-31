import { Module } from '@nestjs/common';
import { ArtistController } from './artist.controller';
import { ArtistService } from './artist.service';

@Module({
  controllers: [ArtistController],
  providers: [ArtistService],
  exports: [ArtistService], // Export service so other modules can use it
})
export class ArtistModule {}
