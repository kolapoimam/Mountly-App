#!/bin/bash
# Notarizes and staples a built DMG. Requires a real Apple Developer
# account with a Developer ID Application certificate and an app-specific
# password or App Store Connect API key — this script does not, and
# cannot, fabricate those. See docs/RELEASE.md for how to obtain them.
set -euo pipefail

DMG_PATH="${1:?usage: notarize.sh <path-to.dmg>}"

: "${TM_NOTARY_PROFILE:?Set TM_NOTARY_PROFILE to a keychain profile created via: xcrun notarytool store-credentials}"

echo "==> Submitting $DMG_PATH for notarization"
xcrun notarytool submit "$DMG_PATH" --keychain-profile "$TM_NOTARY_PROFILE" --wait

echo "==> Stapling notarization ticket"
xcrun stapler staple "$DMG_PATH"

echo "==> Validating staple"
xcrun stapler validate "$DMG_PATH"

echo "==> Notarization complete"
