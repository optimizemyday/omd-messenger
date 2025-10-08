#!/bin/bash

set -e

# Configuration
IMAGE_NAME="omd-messenger"
REGISTRY="registry.optimizemyday.com"
NAMESPACE="omd-ai"
USERNAME="omd-apps"
VERSION=$(node -p "require('./package.json').version")
COMMIT_HASH=$(git rev-parse --short HEAD)

echo "🚀 Pushing OMD Messenger to Docker Registry"
echo "   Registry: $REGISTRY"
echo "   Username: $USERNAME"
echo "   Image: $NAMESPACE/$IMAGE_NAME"
echo "   Version: $VERSION"
echo "   Commit: $COMMIT_HASH"

# Check if image exists locally
if ! docker image inspect $IMAGE_NAME:latest >/dev/null 2>&1; then
    echo "❌ Local image not found. Please run ./build-docker.sh first"
    exit 1
fi

# Login to registry
echo "🔐 Logging into Docker registry..."
echo "Please enter your Docker registry password:"
docker login $REGISTRY --username $USERNAME

# Build and push AMD64 images to registry
echo "📤 Building and pushing AMD64 images to registry..."

# Temporarily use our custom dockerignore
cp .dockerignore .dockerignore.backup
cp .dockerignore.simple .dockerignore

# Create buildx builder if it doesn't exist
docker buildx create --use --name multiplatform 2>/dev/null || docker buildx use multiplatform

# Build and push for AMD64 platform
docker buildx build \
  -f Dockerfile.simple \
  --platform linux/amd64 \
  --build-arg BUILDKIT_INLINE_CACHE=1 \
  --tag $REGISTRY/$NAMESPACE/$IMAGE_NAME:latest \
  --tag $REGISTRY/$NAMESPACE/$IMAGE_NAME:$VERSION \
  --tag $REGISTRY/$NAMESPACE/$IMAGE_NAME:$COMMIT_HASH \
  --push \
  .

# Restore original dockerignore
mv .dockerignore.backup .dockerignore

echo "✅ Successfully pushed all images to registry!"
echo ""
echo "🎯 Available images:"
echo "   📦 $REGISTRY/$NAMESPACE/$IMAGE_NAME:latest"
echo "   📦 $REGISTRY/$NAMESPACE/$IMAGE_NAME:$VERSION"
echo "   📦 $REGISTRY/$NAMESPACE/$IMAGE_NAME:$COMMIT_HASH"
echo ""
echo "🔧 To deploy, use one of these images in your Kubernetes/Docker setup"