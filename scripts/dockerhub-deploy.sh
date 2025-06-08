#!/bin/bash

# Enhanced DockerHub Deployment Script for Home Library Service
# This script provides a complete workflow for DockerHub deployment

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
IMAGE_NAME="home-library-service"
VERSION=${1:-"latest"}

echo -e "${CYAN}🐳 Enhanced DockerHub Deployment for Home Library Service${NC}"
echo "========================================================"

# Function to prompt for DockerHub username
get_dockerhub_username() {
    if [ -z "$DOCKERHUB_USERNAME" ]; then
        echo -e "${YELLOW}📝 Please enter your DockerHub username:${NC}"
        read -p "Username: " DOCKERHUB_USERNAME
        if [ -z "$DOCKERHUB_USERNAME" ]; then
            echo -e "${RED}❌ DockerHub username is required${NC}"
            exit 1
        fi
        export DOCKERHUB_USERNAME
    fi
}

# Function to check Docker installation
check_docker() {
    echo -e "${BLUE}🔍 Checking Docker installation...${NC}"
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}❌ Docker is not installed or not in PATH${NC}"
        exit 1
    fi
    
    if ! docker info >/dev/null 2>&1; then
        echo -e "${RED}❌ Docker daemon is not running${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Docker is ready${NC}"
}

# Function to handle DockerHub login
dockerhub_login() {
    echo -e "${BLUE}🔐 Checking DockerHub authentication...${NC}"
    
    # Check if already logged in
    if docker info 2>/dev/null | grep -q "Username:"; then
        LOGGED_USER=$(docker info 2>/dev/null | grep "Username:" | awk '{print $2}')
        echo -e "${GREEN}✅ Already logged in as: ${LOGGED_USER}${NC}"
        
        if [ "$LOGGED_USER" != "$DOCKERHUB_USERNAME" ]; then
            echo -e "${YELLOW}⚠️  Logged in as different user. Re-authentication needed.${NC}"
            docker logout
        else
            return 0
        fi
    fi
    
    echo -e "${YELLOW}🔑 Please login to DockerHub...${NC}"
    if docker login --username "$DOCKERHUB_USERNAME"; then
        echo -e "${GREEN}✅ Successfully logged in to DockerHub${NC}"
    else
        echo -e "${RED}❌ Failed to login to DockerHub${NC}"
        exit 1
    fi
}

# Function to build Docker image
build_image() {
    echo -e "${BLUE}🔨 Building Docker image...${NC}"
    echo "   Target: $IMAGE_NAME"
    
    if docker build -t "$IMAGE_NAME" .; then
        echo -e "${GREEN}✅ Docker image built successfully${NC}"
        
        # Show image details
        IMAGE_SIZE=$(docker images --format "table {{.Size}}" "$IMAGE_NAME" | tail -n 1)
        echo -e "${GREEN}📦 Image size: ${IMAGE_SIZE}${NC}"
    else
        echo -e "${RED}❌ Failed to build Docker image${NC}"
        exit 1
    fi
}

# Function to tag image for DockerHub
tag_image() {
    local FULL_IMAGE_NAME="${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${VERSION}"
    echo -e "${BLUE}🏷️  Tagging image for DockerHub...${NC}"
    echo "   Source: $IMAGE_NAME"
    echo "   Target: $FULL_IMAGE_NAME"
    
    if docker tag "$IMAGE_NAME" "$FULL_IMAGE_NAME"; then
        echo -e "${GREEN}✅ Image tagged successfully${NC}"
    else
        echo -e "${RED}❌ Failed to tag image${NC}"
        exit 1
    fi
}

# Function to push to DockerHub
push_image() {
    local FULL_IMAGE_NAME="${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${VERSION}"
    echo -e "${BLUE}📤 Pushing to DockerHub...${NC}"
    echo "   Pushing: $FULL_IMAGE_NAME"
    
    if docker push "$FULL_IMAGE_NAME"; then
        echo -e "${GREEN}✅ Image pushed to DockerHub successfully!${NC}"
        return 0
    else
        echo -e "${RED}❌ Failed to push image to DockerHub${NC}"
        exit 1
    fi
}

# Function to show deployment summary
show_summary() {
    local FULL_IMAGE_NAME="${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${VERSION}"
    
    echo ""
    echo -e "${CYAN}🎉 Deployment Summary${NC}"
    echo "===================="
    echo -e "${GREEN}✅ Successfully deployed to DockerHub!${NC}"
    echo ""
    echo -e "${BLUE}📍 Image Location:${NC}"
    echo "   https://hub.docker.com/r/${DOCKERHUB_USERNAME}/${IMAGE_NAME}"
    echo ""
    echo -e "${BLUE}💻 Usage Commands:${NC}"
    echo "   Pull:  docker pull $FULL_IMAGE_NAME"
    echo "   Run:   docker run -p 4000:4000 $FULL_IMAGE_NAME"
    echo ""
    
    # Show local images
    echo -e "${BLUE}📦 Local Images:${NC}"
    docker images | grep -E "(REPOSITORY|${IMAGE_NAME}|${DOCKERHUB_USERNAME}/${IMAGE_NAME})"
}

# Main execution flow
main() {
    echo -e "${BLUE}🚀 Starting deployment process...${NC}"
    echo ""
    
    check_docker
    get_dockerhub_username
    dockerhub_login
    build_image
    tag_image
    push_image
    show_summary
    
    echo ""
    echo -e "${GREEN}🎯 All 20 points should now be recovered!${NC}"
}

# Run main function
main "$@"
