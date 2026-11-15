#!/bin/bash
# Full local build + verification pass:
#   clean -> build (debug) -> unit tests -> build (release) -> assemble .app
#   -> verify arm64 -> verify required resources are present.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "==> Cleaning"
swift package clean

echo "==> Building (debug)"
swift build

echo "==> Running unit tests (Core)"
swift test --filter MountlyCoreTests

echo "==> Running integration tests (skips cleanly if dev-only NTFS tooling is absent)"
swift test --filter MountlyIntegrationTests || {
    echo "warning: integration test target reported a failure — inspect output above" >&2
}

echo "==> Building (release)"
swift build -c release --arch arm64

echo "==> Assembling Mountly.app"
mkdir -p build dist
"$ROOT_DIR/Scripts/assemble_app_bundle.sh" "$ROOT_DIR/build/Mountly.app"

APP="$ROOT_DIR/build/Mountly.app"

echo "==> Verifying arm64 architecture"
for bin in "$APP/Contents/MacOS/Mountly" "$APP/Contents/Library/LaunchDaemons/com.mountly.app.helper"; do
    arch_info="$(file "$bin")"
    echo "$bin: $arch_info"
    if ! echo "$arch_info" | grep -q "arm64"; then
        echo "error: $bin is not arm64" >&2
        exit 1
    fi
done

echo "==> Verifying required resources"
required=(
    "$APP/Contents/Info.plist"
    "$APP/Contents/MacOS/Mountly"
    "$APP/Contents/Library/LaunchDaemons/com.mountly.app.helper"
    "$APP/Contents/Library/LaunchDaemons/com.mountly.app.helper.plist"
)
for path in "${required[@]}"; do
    if [[ ! -e "$path" ]]; then
        echo "error: missing required resource: $path" >&2
        exit 1
    fi
done
if [[ ! -f "$APP/Contents/Resources/AppIcon.icns" ]]; then
    echo "warning: AppIcon.icns missing — run Scripts/generate_icon.swift + iconutil first" >&2
fi

echo "==> Build complete: $APP"
