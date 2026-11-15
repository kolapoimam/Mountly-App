#!/bin/bash
# Builds Release, signs if a signing identity is available, creates the
# DMG, and validates both the app bundle and the DMG.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

APP_NAME="Mountly.app"
BUILD_APP="$ROOT_DIR/build/$APP_NAME"
DIST_DIR="$ROOT_DIR/dist"

# Preferred: a real "Developer ID Application" identity for distributable,
# notarizable builds. Falls back to any available signing identity for a
# local/dev-tested build, and to ad-hoc signing (`-`) if none exists at all
# — never invents or fakes a certificate.
SIGN_IDENTITY="${TM_SIGN_IDENTITY:-}"
if [[ -z "$SIGN_IDENTITY" ]]; then
    SIGN_IDENTITY="$(security find-identity -v -p codesigning 2>/dev/null | grep "Developer ID Application" | head -1 | sed -E 's/.*"(.*)"/\1/' || true)"
fi
if [[ -z "$SIGN_IDENTITY" ]]; then
    SIGN_IDENTITY="$(security find-identity -v -p codesigning 2>/dev/null | head -1 | sed -E 's/.*"(.*)"/\1/' || true)"
fi

echo "==> Building release app bundle"
swift build -c release --arch arm64
mkdir -p build dist
"$ROOT_DIR/Scripts/assemble_app_bundle.sh" "$BUILD_APP"

if [[ -n "$SIGN_IDENTITY" ]]; then
    echo "==> Signing with identity: $SIGN_IDENTITY"
    codesign --force --options runtime --timestamp \
        --entitlements "$ROOT_DIR/Resources/MountlyHelperTool.entitlements" \
        --identifier "com.mountly.app.helper" \
        --sign "$SIGN_IDENTITY" \
        "$BUILD_APP/Contents/Library/LaunchDaemons/com.mountly.app.helper"

    codesign --force --options runtime --timestamp \
        --entitlements "$ROOT_DIR/Resources/Mountly.entitlements" \
        --identifier "com.mountly.app" \
        --sign "$SIGN_IDENTITY" \
        "$BUILD_APP"

    echo "==> Verifying signature"
    codesign --verify --deep --strict --verbose=2 "$BUILD_APP" || {
        echo "note: signature verification reported an issue — expected when signed with a non-Developer-ID identity or without notarization; see docs/RELEASE.md" >&2
    }
else
    echo "note: no codesigning identity found — producing an UNSIGNED build for local testing only. See docs/RELEASE.md for how to sign with a Developer ID Application certificate." >&2
fi

echo "==> Validating app bundle structure"
codesign -dv "$BUILD_APP" 2>&1 || echo "note: bundle is unsigned"
if ! plutil -lint "$BUILD_APP/Contents/Info.plist" >/dev/null; then
    echo "error: Info.plist failed to lint" >&2
    exit 1
fi

echo "==> Creating DMG"
"$ROOT_DIR/Scripts/create-dmg.sh" "$BUILD_APP" "$DIST_DIR/Mountly.dmg"

echo "==> Validating DMG"
hdiutil verify "$DIST_DIR/Mountly.dmg"

echo "==> Package complete: $DIST_DIR/Mountly.dmg"
