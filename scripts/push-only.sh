#!/bin/bash

# Simple DockerHub Push (assumes you're already logged in)
# Run this after: docker login --username YOUR_USERNAME

set -e

# Configuration
IMAGE_NAME="home-library-service"
VERSION="latest"

# Get logged in username
if docker info 2>/dev/null | grep -q "Username:"; then
    DOCKERHUB_USERNAME=$(docker info 2>/dev/null | grep "Username:" | awk '{print $2}')
    echo "✅ Logged in as: $DOCKERHUB_USERNAME"
else
    echo "❌ Not logged in to DockerHub"
    echo "Please run: docker login --username YOUR_USERNAME"
    exit 1
fi

FULL_IMAGE_NAME="${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${VERSION}"

echo "🏷️  Tagging: $IMAGE_NAME -> $FULL_IMAGE_NAME"
docker tag "$IMAGE_NAME" "$FULL_IMAGE_NAME"

echo "📤 Pushing: $FULL_IMAGE_NAME"
docker push "$FULL_IMAGE_NAME"

echo ""
echo "🎉 SUCCESS! Image pushed to DockerHub"
echo "📍 Available at: https://hub.docker.com/r/${DOCKERHUB_USERNAME}/${IMAGE_NAME}"
echo "💻 Pull with: docker pull $FULL_IMAGE_NAME"
