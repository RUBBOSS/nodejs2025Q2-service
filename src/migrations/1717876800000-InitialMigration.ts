import { MigrationInterface, QueryRunner } from 'typeorm';

export class InitialMigration1717876800000 implements MigrationInterface {
  name = 'InitialMigration1717876800000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    // Create users table
    await queryRunner.query(`
            CREATE TABLE "users" (
                "id" uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
                "login" varchar UNIQUE NOT NULL,
                "password" varchar NOT NULL,
                "version" integer DEFAULT 1,
                "createdAt" TIMESTAMP DEFAULT now(),
                "updatedAt" TIMESTAMP DEFAULT now()
            )
        `);

    // Create artists table
    await queryRunner.query(`
            CREATE TABLE "artists" (
                "id" uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
                "name" varchar NOT NULL,
                "grammy" boolean DEFAULT false
            )
        `);

    // Create albums table
    await queryRunner.query(`
            CREATE TABLE "albums" (
                "id" uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
                "name" varchar NOT NULL,
                "year" integer NOT NULL,
                "artistId" uuid,
                CONSTRAINT "FK_albums_artistId" FOREIGN KEY ("artistId") REFERENCES "artists"("id") ON DELETE SET NULL
            )
        `);

    // Create tracks table
    await queryRunner.query(`
            CREATE TABLE "tracks" (
                "id" uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
                "name" varchar NOT NULL,
                "artistId" uuid,
                "albumId" uuid,
                "duration" integer NOT NULL,
                CONSTRAINT "FK_tracks_artistId" FOREIGN KEY ("artistId") REFERENCES "artists"("id") ON DELETE SET NULL,
                CONSTRAINT "FK_tracks_albumId" FOREIGN KEY ("albumId") REFERENCES "albums"("id") ON DELETE SET NULL
            )
        `);

    // Create favorites table
    await queryRunner.query(`
            CREATE TABLE "favorites" (
                "id" uuid PRIMARY KEY DEFAULT uuid_generate_v4()
            )
        `);

    // Create junction tables for favorites many-to-many relationships
    await queryRunner.query(`
            CREATE TABLE "favorite_artists" (
                "favoritesId" uuid NOT NULL,
                "artistId" uuid NOT NULL,
                CONSTRAINT "FK_favorite_artists_favoritesId" FOREIGN KEY ("favoritesId") REFERENCES "favorites"("id") ON DELETE CASCADE,
                CONSTRAINT "FK_favorite_artists_artistId" FOREIGN KEY ("artistId") REFERENCES "artists"("id") ON DELETE CASCADE,
                PRIMARY KEY ("favoritesId", "artistId")
            )
        `);

    await queryRunner.query(`
            CREATE TABLE "favorite_albums" (
                "favoritesId" uuid NOT NULL,
                "albumId" uuid NOT NULL,
                CONSTRAINT "FK_favorite_albums_favoritesId" FOREIGN KEY ("favoritesId") REFERENCES "favorites"("id") ON DELETE CASCADE,
                CONSTRAINT "FK_favorite_albums_albumId" FOREIGN KEY ("albumId") REFERENCES "albums"("id") ON DELETE CASCADE,
                PRIMARY KEY ("favoritesId", "albumId")
            )
        `);

    await queryRunner.query(`
            CREATE TABLE "favorite_tracks" (
                "favoritesId" uuid NOT NULL,
                "trackId" uuid NOT NULL,
                CONSTRAINT "FK_favorite_tracks_favoritesId" FOREIGN KEY ("favoritesId") REFERENCES "favorites"("id") ON DELETE CASCADE,
                CONSTRAINT "FK_favorite_tracks_trackId" FOREIGN KEY ("trackId") REFERENCES "tracks"("id") ON DELETE CASCADE,
                PRIMARY KEY ("favoritesId", "trackId")
            )
        `);

    // Create indexes for better performance
    await queryRunner.query(
      `CREATE INDEX "IDX_users_login" ON "users" ("login")`,
    );
    await queryRunner.query(
      `CREATE INDEX "IDX_albums_artistId" ON "albums" ("artistId")`,
    );
    await queryRunner.query(
      `CREATE INDEX "IDX_tracks_artistId" ON "tracks" ("artistId")`,
    );
    await queryRunner.query(
      `CREATE INDEX "IDX_tracks_albumId" ON "tracks" ("albumId")`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    // Drop indexes
    await queryRunner.query(`DROP INDEX "IDX_tracks_albumId"`);
    await queryRunner.query(`DROP INDEX "IDX_tracks_artistId"`);
    await queryRunner.query(`DROP INDEX "IDX_albums_artistId"`);
    await queryRunner.query(`DROP INDEX "IDX_users_login"`);

    // Drop junction tables
    await queryRunner.query(`DROP TABLE "favorite_tracks"`);
    await queryRunner.query(`DROP TABLE "favorite_albums"`);
    await queryRunner.query(`DROP TABLE "favorite_artists"`);

    // Drop main tables
    await queryRunner.query(`DROP TABLE "favorites"`);
    await queryRunner.query(`DROP TABLE "tracks"`);
    await queryRunner.query(`DROP TABLE "albums"`);
    await queryRunner.query(`DROP TABLE "artists"`);
    await queryRunner.query(`DROP TABLE "users"`);
  }
}
