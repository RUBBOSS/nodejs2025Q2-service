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

## Running application locally (Development)

For local development without Docker:

```bash
# Install dependencies
npm install

# Copy local environment file
cp .env.local .env

# Start PostgreSQL locally (required)
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

```bash
# Run all tests
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

## Security Scanning

```bash
# Run npm audit for security vulnerabilities
npm run audit
```

## Docker Image Information

- **Application Image Size**: ~263MB (optimized multi-stage build)
- **Database**: PostgreSQL 16 Alpine
- **Features**:
  - Hot reloading in development
  - Health checks for both services
  - Persistent volumes for data storage
  - Custom bridge network for service communication
  - Auto-restart on container failure

To run all test with authorization

```
npm run test:auth
```

To run only specific test suite with authorization

```
npm run test:auth -- <path to suite>
```

### Auto-fix and format

```
npm run lint
```

```
npm run format
```

### Debugging in VSCode

Press <kbd>F5</kbd> to debug.

For more information, visit: https://code.visualstudio.com/docs/editor/debugging
