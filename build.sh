#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

APP_NAME="MacUsage"
BUILD_DIR="$SCRIPT_DIR/build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
CONTENTS="$APP_BUNDLE/Contents"
MACOS_DIR="$CONTENTS/MacOS"
RESOURCES_DIR="$CONTENTS/Resources"

echo "==> Building $APP_NAME for macOS (Apple Silicon M4 Pro)..."
mkdir -p "$BUILD_DIR"
mkdir -p ".build/ModuleCache"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

swiftc -parse-as-library -module-cache-path ".build/ModuleCache" \
  -O -whole-module-optimization \
  -target arm64-apple-macosx14.0 \
  -framework SwiftUI \
  -framework AppKit \
  -framework IOKit \
  -framework SystemConfiguration \
  Sources/MacUsage/Main.swift \
  Sources/MacUsage/MenuBarController.swift \
  Sources/MacUsage/Models/SystemMetrics.swift \
  Sources/MacUsage/Models/UIState.swift \
  Sources/MacUsage/Services/MetricsCollector.swift \
  Sources/MacUsage/Views/Components/VisualComponents.swift \
  Sources/MacUsage/Views/Cards/CardViews.swift \
  Sources/MacUsage/Views/DashboardView.swift \
  -o "$MACOS_DIR/$APP_NAME"

cp Resources/Info.plist "$CONTENTS/Info.plist"
echo -n "APPL????" > "$CONTENTS/PkgInfo"

echo "==> Successfully created $APP_BUNDLE"
echo "==> Binary architecture:"
file "$MACOS_DIR/$APP_NAME"
