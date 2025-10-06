#!/bin/bash

set -e

# Configuration
IMAGE_NAME="omd-messenger"
REGISTRY="registry.optimizemyday.com"
NAMESPACE="omd-ai"
VERSION=$(node -p "require('./package.json').version")
COMMIT_HASH=$(git rev-parse --short HEAD)

echo "🏗️  Building OMD Messenger Docker Image"
echo "   Version: $VERSION"
echo "   Commit: $COMMIT_HASH"
echo "   Registry: $REGISTRY/$NAMESPACE/$IMAGE_NAME"

# Switch to Node.js 22
echo "🔧 Switching to Node.js 22..."
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm use 22

# Ensure we have the OMD configuration built
echo "📋 Building OMD configuration..."
yarn config:omd

# Build the Docker image
echo "🐳 Building Docker image..."
docker build \
  --build-arg BUILDKIT_INLINE_CACHE=1 \
  --tag $IMAGE_NAME:latest \
  --tag $IMAGE_NAME:$VERSION \
  --tag $IMAGE_NAME:$COMMIT_HASH \
  --tag $REGISTRY/$NAMESPACE/$IMAGE_NAME:latest \
  --tag $REGISTRY/$NAMESPACE/$IMAGE_NAME:$VERSION \
  --tag $REGISTRY/$NAMESPACE/$IMAGE_NAME:$COMMIT_HASH \
  .

echo "✅ Docker image built successfully!"
echo "   Local tags:"
echo "     - $IMAGE_NAME:latest"
echo "     - $IMAGE_NAME:$VERSION"
echo "     - $IMAGE_NAME:$COMMIT_HASH"
echo "   Registry tags:"
echo "     - $REGISTRY/$NAMESPACE/$IMAGE_NAME:latest"
echo "     - $REGISTRY/$NAMESPACE/$IMAGE_NAME:$VERSION"
echo "     - $REGISTRY/$NAMESPACE/$IMAGE_NAME:$COMMIT_HASH"

# Test the image locally
echo "🧪 Testing the image..."
docker run --rm -d --name omd-messenger-test -p 8080:80 $IMAGE_NAME:latest

# Wait a moment for the container to start
sleep 3

# Test if the container is responding
if curl -f http://localhost:8080/config.json >/dev/null 2>&1; then
    echo "✅ Container test passed!"
else
    echo "❌ Container test failed!"
    docker logs omd-messenger-test
    exit 1
fi

# Clean up test container
docker stop omd-messenger-test

echo "🎉 Build completed successfully!"
echo "To push to registry, run: ./push-docker.sh"