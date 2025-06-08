import { DataSource } from 'typeorm';
import { User, Artist, Album, Track, Favorites } from './src/entities';
import * as dotenv from 'dotenv';

dotenv.config();

export default new DataSource({
  type: 'postgres',
  host: process.env.POSTGRES_HOST || 'localhost',
  port: parseInt(process.env.POSTGRES_PORT || '5432'),
  username: process.env.POSTGRES_USER || 'postgres',
  password: process.env.POSTGRES_PASSWORD || 'rub54321',
  database: process.env.POSTGRES_DB || 'home_library',
  entities: [User, Artist, Album, Track, Favorites],
  migrations: ['src/migrations/*.ts'],
  migrationsTableName: 'migrations',
  synchronize: false,
});
