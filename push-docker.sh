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

# Push all tags
echo "📤 Pushing images to registry..."

echo "  → Pushing latest tag..."
docker push $REGISTRY/$NAMESPACE/$IMAGE_NAME:latest

echo "  → Pushing version tag ($VERSION)..."
docker push $REGISTRY/$NAMESPACE/$IMAGE_NAME:$VERSION

echo "  → Pushing commit tag ($COMMIT_HASH)..."
docker push $REGISTRY/$NAMESPACE/$IMAGE_NAME:$COMMIT_HASH

echo "✅ Successfully pushed all images to registry!"
echo ""
echo "🎯 Available images:"
echo "   📦 $REGISTRY/$NAMESPACE/$IMAGE_NAME:latest"
echo "   📦 $REGISTRY/$NAMESPACE/$IMAGE_NAME:$VERSION"
echo "   📦 $REGISTRY/$NAMESPACE/$IMAGE_NAME:$COMMIT_HASH"
echo ""
echo "🔧 To deploy, use one of these images in your Kubernetes/Docker setup"