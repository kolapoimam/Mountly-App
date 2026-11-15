# Third-Party Licenses

## Plus Jakarta Sans (bundled)

- **Component**: Plus Jakarta Sans, static weight instances (Regular,
  Medium, SemiBold, Bold, ExtraBold) generated from Google's variable font
  release using `fonttools varLib.instancer --update-name-table`.
- **Source**: https://github.com/google/fonts/tree/main/ofl/plusjakartasans
- **License**: SIL Open Font License 1.1 (full text bundled at
  `Sources/Mountly/Resources/Fonts/PlusJakartaSans-OFL.txt`).
- **Bundled in this app?** **Yes** — this is the one component actually
  embedded inside `Mountly.app` (`Contents/Resources/*.bundle/Fonts/`),
  registered process-only via `CTFontManagerRegisterFontsForURL` (never
  installed into the user's system Font Book). The OFL explicitly permits
  bundling, redistribution, and use in applications; the only OFL
  obligation — carrying the license text alongside the font — is satisfied
  by shipping `PlusJakartaSans-OFL.txt` next to the font files.

macFUSE and NTFS-3G, below, are **not** bundled — both are installed
separately, via their own official distribution channels, precisely so
that their license obligations attach to those official installers rather
than to this app's bundle. This section exists so that changes to that
policy (e.g. bundling either component directly) don't happen without
someone re-reading these obligations first.

## macFUSE

- **Component**: macFUSE (system extension + `macFUSE.framework`)
- **Version pinned**: 5.3.3
- **Source**: https://github.com/macfuse/macfuse
- **License**: The macFUSE userspace framework/library portions are
  source-available (BSD/APSL-derived terms per-file); the system-extension
  binary itself is closed-source freeware distributed directly by the
  maintainer (Benjamin Fleischer), notarized by Apple.
- **Bundled in this app?** No. `BackendInstaller` downloads the official
  DMG directly from macFUSE's GitHub Releases over HTTPS, verifies its
  SHA-256 against the value published by the maintainer alongside the
  release, and hands the enclosed `.pkg` to the system's own installer UI.
  Mountly never re-signs, re-packages, or redistributes this
  binary itself.
- **Obligations**: none triggered by this app, since nothing is bundled or
  redistributed — the user downloads directly from the upstream project.

## NTFS-3G (via the `gromgit/fuse` Homebrew tap's `ntfs-3g-mac` formula)

- **Component**: NTFS-3G / ntfsprogs
- **Version observed**: 2026.7.7
- **Upstream source**: https://www.tuxera.com/community/open-source-ntfs-3g/
- **Packaging used**: https://github.com/gromgit/homebrew-fuse (community
  Homebrew tap; mainline Homebrew's own `ntfs-3g` formula is Linux-only as
  of 2026 — see `docs/ARCHITECTURE.md`)
- **License**: `GPL-2.0-or-later AND LGPL-2.0-or-later` (as reported by
  `brew info gromgit/fuse/ntfs-3g-mac` directly against the formula's own
  declared license).
- **Bundled in this app?** No. `BackendInstaller.installNTFS3G` shells out
  to the user's own Homebrew installation (`brew install
  gromgit/fuse/ntfs-3g-mac`), which downloads and installs Tuxera's
  official NTFS-3G/ntfsprogs source distribution, compiled by that
  formula. Nothing from this project is statically or dynamically linked
  into Mountly's own binary.
- **Obligations**: Invoking an independently-installed GPL/LGPL program as
  a separate process (the same relationship `Process`/`ProcessRunner` has
  with `/usr/bin/tar` or `/usr/sbin/diskutil`) does not impose GPL
  copyleft obligations on the invoking application. **If a future version
  of this app ever links `libntfs-3g` directly or embeds its binary inside
  the app bundle, this section must be revisited** — that would very
  likely require either distributing this app itself under
  GPL-compatible terms or providing NTFS-3G's complete corresponding
  source alongside the app, per GPL-2.0 §3 / LGPL-2.0 §6.

## Homebrew

- **Component**: Homebrew (package manager), used only as the delivery
  mechanism for NTFS-3G above.
- **Source**: https://github.com/Homebrew/brew
- **License**: BSD 2-Clause.
- **Bundled?** No — the app checks for an existing Homebrew installation
  and uses it if present; it does not install or embed Homebrew itself.

## Apple system frameworks

Swift, SwiftUI, AppKit, Foundation, DiskArbitration, UserNotifications,
Security, and `os.Logger` are Apple system frameworks used under Xcode's
standard SDK license — not third-party components, and not subject to
this document's redistribution analysis.

## Mountly's own code

All Swift source in `Sources/`, `Tests/`, and `Scripts/` in this repository
is original work written for this project.
