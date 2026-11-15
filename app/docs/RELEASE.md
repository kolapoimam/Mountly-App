# Release Guide

## Versioning

Mountly uses semantic versioning, starting at `1.0.0`
(`Sources/Mountly/UI/MainWindow/RootView.swift`'s `AppVersion`,
and `Resources/Info.plist`'s `CFBundleShortVersionString`). Bump both
together.

## Signing

Mountly targets `Developer ID Application` signing for
distribution outside the Mac App Store, with Hardened Runtime enabled
(required for notarization) and **no App Sandbox** (see `docs/SECURITY.md`
for why).

Two binaries are signed independently, then the outer bundle:

1. `Contents/Library/LaunchDaemons/com.mountly.app.helper`, with
   `Resources/MountlyHelperTool.entitlements` and explicit identifier
   `com.mountly.app.helper`.
2. `Mountly.app` itself, with
   `Resources/Mountly.entitlements` and identifier
   `com.mountly.app`.

`Scripts/package.sh` does this automatically:

```bash
# Preferred: sign with a specific identity
TM_SIGN_IDENTITY="Developer ID Application: Your Name (TEAMID)" ./Scripts/package.sh

# Or let it auto-detect: prefers a "Developer ID Application" identity,
# falls back to any codesigning identity found by `security find-identity`,
# and produces an unsigned build (clearly labeled) if none exists.
./Scripts/package.sh
```

### Development builds

A build signed with an **Apple Development** identity only runs on the Mac
that built it. It cannot be notarized or shared. To produce a build other
people can install, you need an Apple Developer Program membership and a
**Developer ID Application** certificate (Xcode, Settings, Accounts). Then
run `package.sh` again, or set `TM_SIGN_IDENTITY` explicitly.

## Entitlements

See `Resources/Mountly.entitlements` and
`Resources/MountlyHelperTool.entitlements`. Both intentionally omit
`com.apple.security.app-sandbox` (set to `false`) and every entitlement
that would weaken SIP or kernel-level protections. `Mountly`
requests `com.apple.security.network.client` for the backend-installer
downloads; the helper requests nothing beyond default Hardened Runtime
protections.

## Packaging

```bash
./Scripts/build.sh      # clean, debug build, unit tests, release build, assemble .app, verify arch+resources
./Scripts/package.sh    # release build, sign (if possible), create DMG, validate
```

`package.sh` calls `Scripts/assemble_app_bundle.sh` to lay out:

```
Mountly.app/
├── Contents/
│   ├── Info.plist
│   ├── MacOS/Mountly
│   ├── Resources/AppIcon.icns
│   └── Library/LaunchDaemons/
│       ├── com.mountly.app.helper
│       └── com.mountly.app.helper.plist
```

## Notarization

Requires a real Apple Developer account:

```bash
xcrun notarytool store-credentials MountlyProfile \
    --apple-id "you@example.com" --team-id TEAMID --password "app-specific-password"

TM_NOTARY_PROFILE=MountlyProfile ./Scripts/notarize.sh dist/Mountly.dmg
```

`Scripts/notarize.sh` needs a real Apple Developer account and
Developer ID certificate. Never share an unnotarized build outside your own
Macs, because Gatekeeper will block it for everyone else.

## Stapling

`Scripts/notarize.sh` runs `xcrun stapler staple` immediately after a
successful notarization, then validates with `xcrun stapler validate`, so
the DMG works offline for end users (no network check needed at launch).

## DMG generation

`Scripts/create-dmg.sh <path-to-.app> <output.dmg>` builds a DMG
containing only the app and an `Applications` symlink — no
extraneous files — and applies a Finder icon layout via AppleScript
(best-effort; skipped gracefully in non-interactive/headless environments,
which is exactly what happened when this repository's DMG was built —
see the Known Limitations note in the final report).

## Uninstallation

`Scripts/uninstall.sh` removes the app, its preferences, and unregisters
the helper daemon. It never touches macFUSE, NTFS-3G, or any external
drive — see the script's own output for how to remove those separately if
desired.
