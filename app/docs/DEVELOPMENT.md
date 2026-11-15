# Development Guide

## Prerequisites

- Xcode 16+ (Swift 5.10 toolchain) on Apple Silicon.
- macOS 14 (Sonoma) or later.
- Optional, dev-only, for integration tests against a disposable loopback
  NTFS image: `brew install --cask macfuse && brew tap gromgit/fuse && brew
  install gromgit/fuse/ntfs-3g-mac` (see `docs/ARCHITECTURE.md` for why the
  mainline `brew install ntfs-3g` does **not** work on macOS).

## Project layout

```
Sources/
  MountlyCore/   # Models, Services, Filesystem backend abstraction,
                          # Utilities — no SwiftUI/AppKit imports, fully
                          # unit-testable.
  Mountly/       # The SwiftUI app: App/, UI/*, Resources/.
  MountlyHelperTool/    # The privileged XPC helper (main.swift only).
Tests/
  MountlyCoreTests/         # Pure-logic unit tests, no hardware needed.
  MountlyIntegrationTests/  # Loopback NTFS image tests; skip
                                     # themselves if dev tooling is absent.
Resources/                # Info.plist, entitlements, launchd plist — used
                          # by the packaging scripts, not SPM resource
                          # bundling.
Scripts/                  # build.sh, package.sh, create-dmg.sh,
                          # notarize.sh, uninstall.sh, generate_icon.swift.
docs/                     # This file and its siblings.
```

## Building and running

```bash
swift build                 # debug build of all three targets
swift run Mountly  # runs the app directly (not as a signed .app
                             # bundle — the privileged helper won't be
                             # reachable this way; see below)
swift test --filter MountlyCoreTests   # fast, no dependencies
```

Running `swift run` gives you the full UI and Disk Arbitration detection,
but **not** working privileged mount/unmount, since `SMAppService.daemon`
requires the helper to be embedded inside a properly signed `.app` bundle
at `Contents/Library/LaunchDaemons/`. To exercise the real mount path,
build the full bundle instead:

```bash
./Scripts/build.sh
open "build/Mountly.app"
```

## Testing the privileged helper locally

1. Build and sign the app bundle (`./Scripts/package.sh`, using at least a
   local development signing identity).
2. Launch the app once — `AppState.start()` calls
   `HelperRegistrar.registerIfNeeded()`
   (`Sources/MountlyCore/Filesystem/HelperRegistrar.swift`), which calls
   `SMAppService.daemon(plistName:).register()`.
3. **Approve the daemon** in System Settings → General → Login Items &
   Extensions — this is required every time the helper's registration
   status is `.requiresApproval`, not just optionally. Until it's
   approved, any attempt to enable NTFS write access surfaces
   `TMError.helperApprovalRequired` (with a button that deep-links
   straight to that Settings pane via
   `SMAppService.openSystemSettingsLoginItems()`), rather than a bare
   `connectionFailed`.
4. `Diagnostics` in the main window shows the helper's `ping()` response
   under "MountlyHelperTool" once it's reachable.

**A real bug this fixed:** the first shipped build called
`SMAppService.daemon(plistName:)` only in prose (this file, ARCHITECTURE.md,
SECURITY.md) — no code ever actually called `.register()`. The launchd
plist was correctly embedded in the app bundle, but nothing ever told
launchd the mach service existed, so every `HelperClient` XPC connection
failed with `connectionFailed` and NTFS write access could never work.
`HelperRegistrar` is the fix; `NTFSBackend.mount()` now calls
`registerIfNeeded()` before every mount attempt (idempotent, cheap), and
`AppState.start()` also calls it proactively at launch.

## Generating the app icon

```bash
swift Scripts/generate_icon.swift build/AppIcon-1024.png
# then resize into an .iconset and run iconutil — see Scripts/build.sh
# for the exact sips/iconutil invocations used.
```

## Generating NTFS test fixtures

Integration tests build a disposable NTFS image on the fly in a temp
directory (`Tests/MountlyIntegrationTests/NTFSFixtureIntegrationTests.swift`)
using `mkntfs`/`ntfs-3g` from the `gromgit/fuse` tap — never a real
physical disk. No fixture files are checked
into the repository; they're generated and torn down per test run.

## Concurrency model

- `MountlyCore`'s UI-facing state (`DriveStore`, `MountManager`,
  `EjectManager`, `TransferManager`, `SettingsStore`, `EventLog`) is
  `@MainActor`-isolated, matching SwiftUI's own threading model.
- Heavy I/O (`TransferManager`'s chunked copy loop) runs on a `nonisolated`
  function off the main actor, hopping back via `await MainActor.run` only
  for the small, frequent progress-field updates — so large copies never
  block the UI.
- `FilesystemBackend`/`NTFSBackend`/`BackendInstaller` are plain
  `Sendable` structs/actors with no actor affinity, callable from anywhere.
