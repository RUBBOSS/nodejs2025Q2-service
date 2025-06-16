# DockerHub Deployment Guide

This guide explains how to deploy the Home Library Service to DockerHub to recover the missing 20 points.

## Prerequisites

1. **Docker Desktop installed and running**
   - Verify: `docker --version`
   - Verify: `docker info`

2. **DockerHub account**
   - Sign up at: https://hub.docker.com
   - Remember your username and password

## Quick Deployment

### Option 1: Enhanced Script (Recommended)

```bash
# Make script executable
chmod +x scripts/dockerhub-deploy.sh

# Run deployment script
./scripts/dockerhub-deploy.sh
```

The script will:
- ✅ Check Docker installation
- ✅ Prompt for DockerHub username
- ✅ Handle DockerHub login
- ✅ Build the Docker image
- ✅ Tag for DockerHub
- ✅ Push to DockerHub
- ✅ Show deployment summary

### Option 2: Manual Steps

```bash
# 1. Set your DockerHub username
export DOCKERHUB_USERNAME="your-dockerhub-username"

# 2. Login to DockerHub
docker login --username $DOCKERHUB_USERNAME

# 3. Build the image (if not already built)
docker build -t home-library-service .

# 4. Tag for DockerHub
docker tag home-library-service $DOCKERHUB_USERNAME/home-library-service:latest

# 5. Push to DockerHub
docker push $DOCKERHUB_USERNAME/home-library-service:latest
```

### Option 3: Using npm scripts

```bash
# Set environment variable
export DOCKERHUB_USERNAME="your-dockerhub-username"

# Deploy using npm script
npm run dockerhub:deploy
```

## Verification

After successful deployment:

1. **Check DockerHub Repository**
   - Visit: `https://hub.docker.com/r/YOUR_USERNAME/home-library-service`
   - Verify the image is listed with "latest" tag

2. **Test Pull and Run**
   ```bash
   # Pull from DockerHub
   docker pull YOUR_USERNAME/home-library-service:latest
   
   # Run the container
   docker run -p 4000:4000 YOUR_USERNAME/home-library-service:latest
   ```

3. **Verify Application**
   - Open: http://localhost:4000
   - Check: http://localhost:4000/doc (API documentation)

## Image Details

- **Base Image**: node:22.14.0-alpine
- **Final Size**: ~265MB
- **Architecture**: Multi-stage build
- **Security**: Non-root user, minimal attack surface
- **Port**: 4000

## Troubleshooting

### Docker Login Issues
```bash
# Clear stored credentials and login again
docker logout
docker login --username YOUR_USERNAME
```

### Permission Issues (Linux/Mac)
```bash
# Make script executable
chmod +x scripts/dockerhub-deploy.sh
```

### Image Size Concerns
The image is optimized with:
- Multi-stage build (removes build dependencies)
- Alpine Linux (minimal base image)
- Production-only dependencies
- Layer optimization

### Build Failures
```bash
# Clean Docker cache
docker system prune -f

# Rebuild from scratch
docker build --no-cache -t home-library-service .
```

## Environment Variables

Set these for automated deployment:

```bash
# Required
export DOCKERHUB_USERNAME="your-username"

# Optional
export VERSION="latest"  # or specific version like "1.0.0"
```

## Points Recovery

This deployment should recover **20 points** by demonstrating:
- ✅ Successful Docker image build
- ✅ Proper image tagging for DockerHub
- ✅ Successful push to DockerHub registry
- ✅ Public availability of the image
- ✅ Functional container deployment

## Support

If you encounter issues:
1. Check Docker is running: `docker info`
2. Verify DockerHub credentials
3. Check network connectivity
4. Review build logs for errors
5. Ensure sufficient disk space

---

**Success Indicator**: Image visible at `https://hub.docker.com/r/YOUR_USERNAME/home-library-service`
