import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { User, Artist, Album, Track, Favorites } from '../entities';

@Module({
  imports: [
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: (configService: ConfigService) => ({
        type: 'postgres',
        host: configService.get('POSTGRES_HOST', 'localhost'),
        port: parseInt(configService.get('POSTGRES_PORT', '5432')),
        username: configService.get('POSTGRES_USER', 'postgres'),
        password: configService.get('POSTGRES_PASSWORD', 'rub54321'),
        database: configService.get('POSTGRES_DB', 'home_library'),
        entities: [User, Artist, Album, Track, Favorites],
        migrations: ['dist/migrations/*.js'],
        migrationsTableName: 'migrations',
        migrationsRun: process.env.NODE_ENV !== 'production',
        synchronize: process.env.NODE_ENV === 'development',
        logging: ['query', 'error'],
        retryAttempts: 3,
        retryDelay: 3000,
        autoLoadEntities: true,
      }),
      inject: [ConfigService],
    }),
  ],
})
export class DatabaseModule {}
