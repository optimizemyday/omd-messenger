#!/bin/bash

set -e

# Configuration
IMAGE_NAME="omd-messenger"
REGISTRY="registry.optimizemyday.com"
NAMESPACE="omd-ai"
VERSION=$(node -p "require('./package.json').version")
COMMIT_HASH=$(git rev-parse --short HEAD)

echo "🚀 Building OMD Messenger Docker Image (Simple)"
echo "   Version: $VERSION"
echo "   Commit: $COMMIT_HASH"
echo "   Registry: $REGISTRY/$NAMESPACE/$IMAGE_NAME"

# Check for uncommitted changes
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "❌ You have uncommitted changes. Please commit them before building."
  exit 1
fi

# Check if local branch is ahead of remote
LOCAL_BRANCH=$(git rev-parse --abbrev-ref HEAD)
UPSTREAM_BRANCH="origin/$LOCAL_BRANCH"
git fetch origin

if [ "$(git rev-list --count $UPSTREAM_BRANCH..$LOCAL_BRANCH)" -ne 0 ]; then
  echo "❌ You have commits that are not pushed to origin. Please push them before building."
  exit 1
fi

echo "✅ All changes are committed and pushed."

# Remove existing webapp directory if it exists
if [ -d "webapp" ]; then
    echo "🗑️  Removing existing webapp directory..."
    rm -rf webapp
fi


export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

nvm use 22 && yarn config:omd && yarn build

# Check if config.json exists in webapp
if [ ! -f "webapp/config.json" ]; then
    echo "❌ webapp/config.json not found!"
    echo "   Please run: yarn config:omd"
    exit 1
fi

echo "✅ webapp directory found with config.json"

# Build the Docker image using simple Dockerfile for AMD64 platform
echo "🐳 Building Docker image for AMD64 platform..."

# Temporarily use our custom dockerignore
cp .dockerignore .dockerignore.backup
cp .dockerignore.simple .dockerignore

# Create buildx builder if it doesn't exist
docker buildx create --use --name multiplatform 2>/dev/null || docker buildx use multiplatform

# Build for AMD64 platform (compatible with most Kubernetes clusters)
# Build locally for testing
docker buildx build \
  -f Dockerfile.simple \
  --platform linux/amd64 \
  --build-arg BUILDKIT_INLINE_CACHE=1 \
  --tag $IMAGE_NAME:latest \
  --tag $IMAGE_NAME:$VERSION \
  --tag $IMAGE_NAME:$COMMIT_HASH \
  --tag $REGISTRY/$NAMESPACE/$IMAGE_NAME:latest \
  --tag $REGISTRY/$NAMESPACE/$IMAGE_NAME:$VERSION \
  --tag $REGISTRY/$NAMESPACE/$IMAGE_NAME:$COMMIT_HASH \
  --load \
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
docker run --rm -d --name omd-messenger-test -p 8081:80 $IMAGE_NAME:latest

# Wait a moment for the container to start
sleep 3

# Test if the container is responding
if curl -f http://localhost:8081/config.json >/dev/null 2>&1; then
    echo "✅ Container test passed!"
    echo "   You can test the app at: http://localhost:8081"
    echo "   Press any key to stop the test container and continue..."
    read -n 1 -s
else
    echo "❌ Container test failed!"
    docker logs omd-messenger-test
    docker stop omd-messenger-test
    exit 1
fi

# Clean up test container
docker stop omd-messenger-test

echo "🎉 Build completed successfully!"
echo ""
echo "🎯 Local images built:"
echo "   📦 $IMAGE_NAME:latest"
echo "   📦 $IMAGE_NAME:$VERSION"
echo "   📦 $IMAGE_NAME:$COMMIT_HASH"
echo ""
echo "🚀 To push to registry after testing, run: ./push-docker.sh"