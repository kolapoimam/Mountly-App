#!/bin/bash
# Assembles Mountly.app from already-built Release binaries.
# Shared by build.sh (unsigned, for local verification) and package.sh
# (which signs the result afterwards). Never touches anything outside the
# build output / dist directories.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$ROOT_DIR/.build/release"
OUT_APP="${1:-$ROOT_DIR/build/Mountly.app}"

APP_BIN="$BUILD_DIR/Mountly"
HELPER_BIN="$BUILD_DIR/MountlyHelperTool"

if [[ ! -x "$APP_BIN" ]]; then
    echo "error: $APP_BIN not found — run 'swift build -c release' first" >&2
    exit 1
fi
if [[ ! -x "$HELPER_BIN" ]]; then
    echo "error: $HELPER_BIN not found — run 'swift build -c release' first" >&2
    exit 1
fi

rm -rf "$OUT_APP"
mkdir -p "$OUT_APP/Contents/MacOS"
mkdir -p "$OUT_APP/Contents/Resources"
mkdir -p "$OUT_APP/Contents/Library/LaunchDaemons"

cp "$APP_BIN" "$OUT_APP/Contents/MacOS/Mountly"
cp "$ROOT_DIR/Resources/Info.plist" "$OUT_APP/Contents/Info.plist"

if [[ -f "$ROOT_DIR/build/AppIcon.icns" ]]; then
    cp "$ROOT_DIR/build/AppIcon.icns" "$OUT_APP/Contents/Resources/AppIcon.icns"
else
    echo "warning: build/AppIcon.icns not found — app will have no custom icon" >&2
fi

# SPM's resource bundle for the app target (currently just the (empty)
# Assets.xcassets placeholder) — copy through if SwiftPM produced one.
RESOURCE_BUNDLE="$BUILD_DIR/Mountly_Mountly.bundle"
if [[ -d "$RESOURCE_BUNDLE" ]]; then
    cp -R "$RESOURCE_BUNDLE" "$OUT_APP/Contents/Resources/"
fi

# Privileged helper, embedded per SMAppService.daemon requirements: the
# executable and its launchd plist live side by side under
# Contents/Library/LaunchDaemons.
cp "$HELPER_BIN" "$OUT_APP/Contents/Library/LaunchDaemons/com.mountly.app.helper"
cp "$ROOT_DIR/Resources/com.mountly.app.helper.plist" "$OUT_APP/Contents/Library/LaunchDaemons/com.mountly.app.helper.plist"

chmod +x "$OUT_APP/Contents/MacOS/Mountly"
chmod +x "$OUT_APP/Contents/Library/LaunchDaemons/com.mountly.app.helper"

echo "Assembled: $OUT_APP"
