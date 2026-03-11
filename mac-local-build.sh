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

cd "$SYPHON_DIR"

# Build arm64
echo "Building Release arm64..."
xcodebuild -project Syphon.xcodeproj \
  -scheme Syphon \
  -configuration Release \
  -arch arm64 \
  -derivedDataPath ../build/arm64 \
  ONLY_ACTIVE_ARCH=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  clean build

# Build x64
echo "Building Release x64..."
xcodebuild -project Syphon.xcodeproj \
  -scheme Syphon \
  -configuration Release \
  -arch x86_64 \
  -derivedDataPath ../build/x64 \
  ONLY_ACTIVE_ARCH=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  clean build

cd ..

# Find the built frameworks
ARM64_FW=$(find build/arm64 -name "Syphon.framework" -path "*/Release/*" | head -1)
X64_FW=$(find build/x64 -name "Syphon.framework" -path "*/Release/*" | head -1)

echo "arm64 framework: $ARM64_FW"
echo "x64 framework: $X64_FW"

# Create universal framework
echo "Creating universal framework..."
mkdir -p build/Release
cp -R "$ARM64_FW" build/Release/Syphon.framework

lipo -create \
  "$ARM64_FW/Versions/A/Syphon" \
  "$X64_FW/Versions/A/Syphon" \
  -output build/Release/Syphon.framework/Versions/A/Syphon

echo "Verifying universal binary..."
lipo -info build/Release/Syphon.framework/Versions/A/Syphon

echo ""
echo "=== Success ==="
echo "Universal framework: build/Release/Syphon.framework"
