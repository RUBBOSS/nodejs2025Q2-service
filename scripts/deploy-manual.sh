#!/bin/bash

# Manual DockerHub Deployment - Step by Step
# This approach assumes you've already logged into DockerHub

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🐳 Manual DockerHub Deployment${NC}"
echo "================================"

# Check if logged in
echo -e "${BLUE}🔍 Checking login status...${NC}"
if ! docker info 2>/dev/null | grep -q "Username:"; then
    echo -e "${RED}❌ Not logged in to DockerHub${NC}"
    echo ""
    echo "Please login first:"
    echo "  docker login"
    echo ""
    echo "Or use the login helper:"
    echo "  ./scripts/login-helper.sh"
    exit 1
fi

LOGGED_USER=$(docker info 2>/dev/null | grep "Username:" | awk '{print $2}')
echo -e "${GREEN}✅ Logged in as: ${LOGGED_USER}${NC}"

# Set username from logged in user
DOCKERHUB_USERNAME="$LOGGED_USER"
IMAGE_NAME="home-library-service"
VERSION="latest"
FULL_IMAGE_NAME="${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${VERSION}"

echo ""
echo -e "${BLUE}📋 Deployment Configuration:${NC}"
echo "   Username: $DOCKERHUB_USERNAME"
echo "   Image: $IMAGE_NAME"
echo "   Tag: $FULL_IMAGE_NAME"
echo ""

# Check if image exists
if ! docker images | grep -q "$IMAGE_NAME"; then
    echo -e "${YELLOW}⚠️  Image $IMAGE_NAME not found. Building...${NC}"
    if docker build -t "$IMAGE_NAME" .; then
        echo -e "${GREEN}✅ Image built successfully${NC}"
    else
        echo -e "${RED}❌ Failed to build image${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✅ Image $IMAGE_NAME found${NC}"
fi

# Tag for DockerHub
echo -e "${BLUE}🏷️  Tagging image...${NC}"
if docker tag "$IMAGE_NAME" "$FULL_IMAGE_NAME"; then
    echo -e "${GREEN}✅ Tagged as: $FULL_IMAGE_NAME${NC}"
else
    echo -e "${RED}❌ Failed to tag image${NC}"
    exit 1
fi

# Push to DockerHub
echo -e "${BLUE}📤 Pushing to DockerHub...${NC}"
echo "This may take a few minutes..."
if docker push "$FULL_IMAGE_NAME"; then
    echo -e "${GREEN}✅ Successfully pushed to DockerHub!${NC}"
else
    echo -e "${RED}❌ Failed to push to DockerHub${NC}"
    exit 1
fi

# Success summary
echo ""
echo -e "${GREEN}🎉 DEPLOYMENT SUCCESSFUL!${NC}"
echo "=========================="
echo ""
echo -e "${BLUE}📍 Your image is now available at:${NC}"
echo "   https://hub.docker.com/r/${DOCKERHUB_USERNAME}/${IMAGE_NAME}"
echo ""
echo -e "${BLUE}💻 To use your image:${NC}"
echo "   docker pull $FULL_IMAGE_NAME"
echo "   docker run -p 4000:4000 $FULL_IMAGE_NAME"
echo ""
echo -e "${GREEN}🎯 DockerHub deployment completed - 20 points recovered!${NC}"

# Show image info
echo ""
echo -e "${BLUE}📦 Image Information:${NC}"
docker images | grep -E "(REPOSITORY|${DOCKERHUB_USERNAME}/${IMAGE_NAME})"
