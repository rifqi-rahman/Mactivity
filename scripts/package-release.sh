#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$SCRIPT_DIR"

APP_NAME="Mactivity"
BUILD_DIR="$SCRIPT_DIR/build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
DIST_DIR="$SCRIPT_DIR/dist"
STAGING_DIR="$DIST_DIR/staging"
VERSION="${1:-1.0.0}"
DMG_NAME="$APP_NAME.dmg"
ZIP_NAME="$APP_NAME.zip"

echo "=================================================="
echo " Packaging $APP_NAME v$VERSION for macOS"
echo "=================================================="

# 1. Compile the native app if not already built or if rebuild requested
if [ "$REBUILD" = "1" ] || [ ! -d "$APP_BUNDLE" ]; then
  echo "==> Building $APP_BUNDLE via build.sh..."
  ./build.sh
fi

if [ ! -d "$APP_BUNDLE" ]; then
  echo "Error: $APP_BUNDLE not found. Build failed."
  exit 1
fi

# 2. Prepare dist directory
mkdir -p "$DIST_DIR"
rm -rf "$STAGING_DIR"
mkdir -p "$STAGING_DIR"

echo "==> Staging application bundle..."
cp -R "$APP_BUNDLE" "$STAGING_DIR/"
ln -s /Applications "$STAGING_DIR/Applications"

# 3. Create macOS Disk Image (DMG)
echo "==> Generating $DMG_NAME with Applications shortcut..."
rm -f "$DIST_DIR/$DMG_NAME"
hdiutil create \
  -volname "$APP_NAME" \
  -srcfolder "$STAGING_DIR" \
  -ov \
  -format UDZO \
  "$DIST_DIR/$DMG_NAME"

# 4. Create ZIP archive preserving macOS attributes
echo "==> Generating $ZIP_NAME..."
rm -f "$DIST_DIR/$ZIP_NAME"
ditto -c -k --keepParent "$APP_BUNDLE" "$DIST_DIR/$ZIP_NAME"

# 5. Clean staging directory
rm -rf "$STAGING_DIR"

# 6. Generate SHA-256 Checksums
echo "==> Generating SHA256 checksums..."
cd "$DIST_DIR"
shasum -a 256 "$DMG_NAME" "$ZIP_NAME" > SHA256SUMS.txt
cd "$SCRIPT_DIR"

echo "=================================================="
echo " Packaging Complete!"
echo " Artifacts located in $DIST_DIR:"
ls -lh "$DIST_DIR"
echo "=================================================="
cat "$DIST_DIR/SHA256SUMS.txt"
echo "=================================================="
