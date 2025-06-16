# Home Library Service

## Prerequisites

- Git - [Download & Install Git](https://git-scm.com/downloads).
- Docker & Docker Compose - [Download & Install Docker](https://docs.docker.com/get-docker/).
- Node.js (optional, for local development) - [Download & Install Node.js](https://nodejs.org/en/download/).

## Downloading

```bash
git clone {repository URL}
cd nodejs2025Q2-service
```

## Running application with Docker (Recommended)

The application is fully containerized and can be run with Docker Compose:

```bash
# Build and start all services (PostgreSQL + NestJS app)
docker-compose up --build

# Run in detached mode
docker-compose up -d

# Stop all services
docker-compose down

# Remove volumes (clean slate)
docker-compose down -v
```

The application will be available at http://localhost:4000

### Docker Image Information

- **Application Image Size**: ~263MB (optimized multi-stage build)
- **Database**: PostgreSQL 16 Alpine
- **Features**:
  - Hot reloading in development
  - Health checks for both services
  - Persistent volumes for data storage
  - Custom bridge network for service communication
  - Auto-restart on container failure

## Running application locally (Development)

For local development without Docker:

```bash
# Install dependencies
npm install

# Start PostgreSQL locally (required)
# Option 1: Use Docker for database only
docker-compose up postgres -d

# Option 2: Use local PostgreSQL installation
# Make sure PostgreSQL is running on localhost:5432

# Run database migrations
npm run migration:run

# Start the application
npm start

# Or start in development mode with hot reload
npm run start:dev
```

## Database Migrations

The application uses TypeORM migrations for database schema management:

```bash
# Run migrations
npm run migration:run

# Revert last migration
npm run migration:revert

# Generate new migration (after entity changes)
npm run migration:generate -- src/migrations/MigrationName
```

## API Documentation

After starting the app on port 4000, you can access the OpenAPI documentation at:
http://localhost:4000/doc/

For more information about OpenAPI/Swagger, visit https://swagger.io/.

## Testing

### Prerequisites for E2E Tests
The e2e tests require:
1. The application running on http://localhost:4000
2. PostgreSQL database running (via Docker or locally)
3. Clean database state before running tests

### Running Tests

```bash
# Start the application and database first
npm run start:dev
# or use Docker:
docker-compose up postgres -d

# Run all e2e tests
npm run test

# Run tests with authentication
npm run test:auth

# Run refresh token tests
npm run test:refresh

# Run tests in watch mode
npm run test:watch

# Run tests with coverage
npm run test:cov
```

### Database Cleanup for Tests
If tests fail due to duplicate key constraints, clean the test database:

```bash
# Clean database tables (Docker)
docker exec -it home-library-db psql -U postgres -d home_library -c "TRUNCATE TABLE users, artists, albums, tracks, favorites CASCADE;"

# Then re-run tests
npm run test
```

## Additional Commands

### Security Scanning

```bash
# Run npm audit for security vulnerabilities
npm run audit

# Run comprehensive security scan
npm run security:full
```

### Auto-fix and format

```bash
npm run lint
```

```bash
npm run format
```

### Debugging in VSCode

Press <kbd>F5</kbd> to debug.

For more information, visit: https://code.visualstudio.com/docs/editor/debugging
