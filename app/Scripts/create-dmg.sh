#!/bin/bash
# Builds a clean, professional-looking DMG: the app + an Applications
# shortcut, no extraneous files, a plain background and sensible icon
# layout set via Finder/AppleScript.
set -euo pipefail

APP_PATH="${1:?usage: create-dmg.sh <path-to-.app> <output-dmg-path>}"
OUT_DMG="${2:?usage: create-dmg.sh <path-to-.app> <output-dmg-path>}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK_DIR="$(mktemp -d)"
# The source folder hdiutil scans must NOT contain the output .dmg itself —
# otherwise hdiutil tries to include its own (growing) output file as
# source content, which fills the disk. Keep them as siblings.
STAGING_DIR="$WORK_DIR/src"
mkdir -p "$STAGING_DIR"
VOL_NAME="Mountly"

trap 'rm -rf "$WORK_DIR"' EXIT

cp -R "$APP_PATH" "$STAGING_DIR/Mountly.app"
ln -s /Applications "$STAGING_DIR/Applications"

mkdir -p "$(dirname "$OUT_DMG")"
rm -f "$OUT_DMG"

TMP_DMG="$WORK_DIR/tmp.dmg"
hdiutil create -volname "$VOL_NAME" -srcfolder "$STAGING_DIR" -ov -format UDRW "$TMP_DMG" >/dev/null

MOUNT_OUT="$(hdiutil attach -readwrite -noverify -noautoopen "$TMP_DMG")"
MOUNT_POINT="$(echo "$MOUNT_OUT" | grep "/Volumes/" | awk -F '\t' '{print $NF}' | head -1)"

# Best-effort Finder window layout (icon positions/background). If
# osascript/Finder scripting isn't available (e.g. headless CI), skip
# cosmetics rather than failing the build.
osascript <<EOF || echo "note: skipped Finder icon layout (non-interactive environment)"
tell application "Finder"
    tell disk "$VOL_NAME"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set the bounds of container window to {100, 100, 640, 420}
        set viewOptions to the icon view options of container window
        set arrangement of viewOptions to not arranged
        set icon size of viewOptions to 96
        set position of item "Mountly.app" of container window to {140, 160}
        set position of item "Applications" of container window to {380, 160}
        close
        open
        update without registering applications
        delay 1
    end tell
end tell
EOF

sync
hdiutil detach "$MOUNT_POINT" >/dev/null 2>&1 || hdiutil detach "$MOUNT_POINT" -force >/dev/null

hdiutil convert "$TMP_DMG" -format UDZO -imagekey zlib-level=9 -o "$OUT_DMG" >/dev/null

echo "Created $OUT_DMG"
