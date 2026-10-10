#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

APP_NAME="Mactivity"
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
  Sources/MacUsage/Services/WindowManager.swift \
  Sources/MacUsage/Views/Components/VisualComponents.swift \
  Sources/MacUsage/Views/Cards/CardViews.swift \
  Sources/MacUsage/Views/DashboardView.swift \
  Sources/MacUsage/Views/Inspector/InspectorWindowView.swift \
  -o "$MACOS_DIR/$APP_NAME"

cp Resources/Info.plist "$CONTENTS/Info.plist"
if [ -f "Resources/AppIcon.icns" ]; then
  cp Resources/AppIcon.icns "$RESOURCES_DIR/AppIcon.icns"
  cp Resources/AppIcon.icns "$RESOURCES_DIR/AppIcon"
fi
if [ -f "Mactivity.icon/Mactivity-iOS-Default-1024@1x.png" ]; then
  cp "Mactivity.icon/Mactivity-iOS-Default-1024@1x.png" "$RESOURCES_DIR/AppIcon.png"
fi
echo -n "APPL????" > "$CONTENTS/PkgInfo"

if [ -f "Resources/AppIcon.icns" ]; then
  swiftc -module-cache-path ".build/ModuleCache" -target arm64-apple-macosx14.0 -e 'import AppKit
  if let img = NSImage(contentsOfFile: "Resources/AppIcon.icns") {
      _ = NSWorkspace.shared.setIcon(img, forFile: "'"$APP_BUNDLE"'", options: [])
  }' -o .build/set_icon_temp && .build/set_icon_temp >/dev/null 2>&1 || true
fi

touch "$APP_BUNDLE"
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$APP_BUNDLE" >/dev/null 2>&1 || true
mdimport "$APP_BUNDLE" >/dev/null 2>&1 || true

echo "==> Successfully created $APP_BUNDLE"
echo "==> Binary architecture:"
file "$MACOS_DIR/$APP_NAME"
