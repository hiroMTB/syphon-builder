#!/bin/bash
set -euo pipefail

SYPHON_REPO="https://github.com/Syphon/Syphon-Framework.git"
SYPHON_REVISION="71351d4b484cd2d1917867f7846a5cdca724552d"
SYPHON_DIR="Syphon-Framework"

echo "=== Syphon Framework Builder ==="
echo "Revision: $SYPHON_REVISION"

# Clone or reset
if [ -d "$SYPHON_DIR" ]; then
  echo "Resetting existing checkout..."
  cd "$SYPHON_DIR"
  git am --abort 2>/dev/null || true
  git reset --hard "$SYPHON_REVISION"
  git clean -fd
  cd ..
else
  echo "Cloning Syphon Framework..."
  git clone "$SYPHON_REPO" "$SYPHON_DIR"
  cd "$SYPHON_DIR"
  git checkout "$SYPHON_REVISION"
  cd ..
fi

# Apply patches if any exist
PATCHES=(patches/*.patch)
if [ -f "${PATCHES[0]}" ]; then
  echo "Applying patches..."
  cd "$SYPHON_DIR"
  git am ../patches/*.patch
  cd ..
else
  echo "No patches to apply."
fi

# Build universal (arm64 + x86_64) in one pass
echo "Building Release universal..."
cd "$SYPHON_DIR"
xcodebuild -project Syphon.xcodeproj \
  -scheme Syphon \
  -configuration Release \
  -derivedDataPath ../build \
  ONLY_ACTIVE_ARCH=NO \
  ARCHS="arm64 x86_64" \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  clean build
cd ..

echo ""
echo "Verifying universal binary..."
lipo -info build/Build/Products/Release/Syphon.framework/Versions/A/Syphon

echo ""
echo "=== Success ==="
echo "Universal framework: build/Build/Products/Release/Syphon.framework"
