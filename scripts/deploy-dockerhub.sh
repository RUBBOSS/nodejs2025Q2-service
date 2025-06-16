#!/bin/bash

# DockerHub Deployment Script for Home Library Service
# This script builds and pushes the Docker image to DockerHub

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
IMAGE_NAME="home-library-service"
DEFAULT_DOCKERHUB_USERNAME="your-dockerhub-username"
VERSION=${1:-"latest"}

echo -e "${BLUE}🐳 DockerHub Deployment Script for Home Library Service${NC}"
echo "================================================"

# Check if DockerHub username is provided
if [ -z "$DOCKERHUB_USERNAME" ]; then
    echo -e "${YELLOW}⚠️  DOCKERHUB_USERNAME environment variable not set${NC}"
    echo -e "${YELLOW}   Using default: ${DEFAULT_DOCKERHUB_USERNAME}${NC}"
    echo -e "${YELLOW}   Set your username: export DOCKERHUB_USERNAME=your-username${NC}"
    DOCKERHUB_USERNAME=$DEFAULT_DOCKERHUB_USERNAME
fi

FULL_IMAGE_NAME="${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${VERSION}"

echo -e "${BLUE}📋 Configuration:${NC}"
echo "   Docker Hub Username: $DOCKERHUB_USERNAME"
echo "   Image Name: $IMAGE_NAME"
echo "   Full Image: $FULL_IMAGE_NAME"
echo "   Version: $VERSION"
echo ""

# Step 1: Build the Docker image
echo -e "${BLUE}🔨 Step 1: Building Docker image...${NC}"
docker build -t $IMAGE_NAME .
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Docker image built successfully${NC}"
else
    echo -e "${RED}❌ Failed to build Docker image${NC}"
    exit 1
fi

# Step 2: Tag the image for DockerHub
echo -e "${BLUE}🏷️  Step 2: Tagging image for DockerHub...${NC}"
docker tag $IMAGE_NAME $FULL_IMAGE_NAME
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Image tagged successfully${NC}"
else
    echo -e "${RED}❌ Failed to tag image${NC}"
    exit 1
fi

# Step 3: Check if user is logged in to DockerHub
echo -e "${BLUE}🔐 Step 3: Checking DockerHub login status...${NC}"
if ! docker info | grep -q "Username"; then
    echo -e "${YELLOW}⚠️  Not logged in to DockerHub${NC}"
    echo -e "${YELLOW}   Please login first: docker login${NC}"
    read -p "Do you want to login now? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker login
    else
        echo -e "${RED}❌ Cannot push without DockerHub login${NC}"
        exit 1
    fi
fi

# Step 4: Push to DockerHub
echo -e "${BLUE}📤 Step 4: Pushing to DockerHub...${NC}"
docker push $FULL_IMAGE_NAME
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Image pushed to DockerHub successfully!${NC}"
else
    echo -e "${RED}❌ Failed to push image to DockerHub${NC}"
    exit 1
fi

# Step 5: Show image information
echo -e "${BLUE}📊 Step 5: Image Information${NC}"
docker images | grep $IMAGE_NAME | head -1
IMAGE_SIZE=$(docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | grep "${IMAGE_NAME}" | head -1 | awk '{print $3}')
echo -e "${GREEN}📦 Image Size: ${IMAGE_SIZE}${NC}"

echo ""
echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
echo -e "${GREEN}📍 Your image is available at: https://hub.docker.com/r/${DOCKERHUB_USERNAME}/${IMAGE_NAME}${NC}"
echo ""
echo -e "${BLUE}💡 To pull the image:${NC}"
echo "   docker pull $FULL_IMAGE_NAME"
echo ""
echo -e "${BLUE}💡 To run the image:${NC}"
echo "   docker run -p 4000:4000 $FULL_IMAGE_NAME"
