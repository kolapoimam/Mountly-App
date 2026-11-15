#!/bin/bash
# Clean uninstall. Removes only Mountly's own application,
# support files, and helper daemon registration. Never touches external
# drives, their contents, or any partition/filesystem metadata — there is
# no code path in this script that references a disk device at all.
set -euo pipefail

echo "This will remove Mountly, its preferences, and its helper daemon."
echo "It will NOT touch any external drive or its files."
read -r -p "Continue? [y/N] " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Cancelled."
    exit 0
fi

echo "==> Unregistering privileged helper (if registered)"
launchctl bootout system/com.mountly.app.helper 2>/dev/null || true

echo "==> Removing application"
if [[ -d "/Applications/Mountly.app" ]]; then
    rm -rf "/Applications/Mountly.app"
fi

echo "==> Removing preferences and application support files"
defaults delete com.mountly.app 2>/dev/null || true
rm -rf "$HOME/Library/Application Support/Mountly" 2>/dev/null || true
rm -rf "$HOME/Library/Preferences/com.mountly.app.plist" 2>/dev/null || true
rm -rf "$HOME/Library/Logs/Mountly" 2>/dev/null || true

cat <<'EOF'

Mountly has been removed.

Note: macFUSE and NTFS-3G were installed separately (via their own official
installers / Homebrew) and are NOT removed by this script, since other
software on your Mac may also depend on them. To remove macFUSE, use its own
uninstaller (see https://osxfuse.github.io — "Uninstalling macFUSE"), and to
remove NTFS-3G run: brew uninstall ntfs-3g
EOF
