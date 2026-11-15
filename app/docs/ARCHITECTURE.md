# Mountly — Architecture & Backend Selection

Status: **Decided** (2026-09-06, extended 2026-09-06 with the filesystem
plugin model). This document is written before any application code, per
the project's safety-first requirement, and records the research that led
to the backend choices below. It should be re-read whenever a backend is
reconsidered.

## 1. Problem statement

Mountly is a manufacturer-agnostic external-drive utility: it identifies a
connected drive by its **filesystem**, never by which company made the
enclosure. macOS already reads most filesystem types external drives use
(exFAT, FAT32, APFS, HFS+) with full read/write support, and reads NTFS but
refuses to write to it. Mountly's job is to (a) safely surface exactly what
state every connected drive is in regardless of filesystem, and (b) add
safe, verified read/write access to NTFS — the one common case macOS
doesn't already handle — without ever touching a partition table,
filesystem metadata, or a user's files in a way the user did not explicitly
request. Section 6 below covers how this generalizes to other filesystems
without hard-coding anything to a single drive type or manufacturer.

Every decision below is optimized for that constraint, in this order:
**do not risk the data > do not require weakening macOS security > convenience.**

## 2. Current macOS NTFS landscape (researched 2026-09-06)

### 2.1 In-box driver
- macOS mounts NTFS volumes automatically, read-only, via a built-in kext-less
  driver (and, on macOS 15.4+/26, a built-in **FSKit** NTFS module).
- No write support. No configuration changes this app makes affect it — we
  never modify or replace `/sbin/mount_ntfs` or any Apple system binary.

### 2.2 FSKit (Apple's userspace filesystem framework, macOS 15.4+ / macOS 26)
- Lets third parties implement filesystems entirely in userspace, no kernel
  extension, no kext-signing entitlement, sandboxable extension model.
- **Blocking problem found during research:** Apple's own built-in NTFS FSKit
  module is read-only and, per current developer reports (Apple Developer
  Forums, thread on "FSKit module mount fails with permission error on
  physical disks"), **third-party FSKit NTFS modules are masked during Disk
  Arbitration probing by the system's built-in read-only NTFS module** — DA
  matches the in-box module first, so a third-party FSKit NTFS extension
  frequently never gets the chance to claim the volume on physical disks.
  Paragon has shipped a commercial FSKit NTFS driver, but there is no mature,
  actively-maintained **open-source** FSKit NTFS implementation that reliably
  works around this in 2026.
- **Decision:** FSKit is the right long-term direction (no kernel component,
  Apple-native), but it is not yet a safe primary backend for v1. It is kept
  as a documented future `FilesystemBackend` implementation (see §6) to adopt
  once the masking issue is resolved upstream.

### 2.3 FUSE-T
- Kext-less: implements FUSE by running a local NFSv4/SMB loopback server
  instead of a kernel extension or system extension. Elegant, no Privacy &
  Security approval step.
- **Licensing problem:** FUSE-T is free for personal use only; embedding or
  shipping it inside a distributed product requires a **commercial license**
  from its author. That is incompatible with bundling it into a freely
  distributed app without a paid agreement in place.
- **Decision:** documented as a viable *user-installed* alternative for
  advanced users (Settings → Advanced can report its presence), but not
  something Mountly bundles or silently installs.

### 2.4 macFUSE + NTFS-3G
- **macFUSE**: the actively maintained successor to osxfuse/MacFUSE
  (maintainer: Benjamin Fleischer). Ships a small, Apple-notarized **system
  extension** (not a kernel extension on current macOS) that the user approves
  once in System Settings → Privacy & Security. The userspace framework
  (`macFUSE.framework`, `libfuse`) is source-available; the system-extension
  binary itself is closed-source freeware, notarized by Apple, and does not
  require disabling SIP or lowering security. Actively maintained, wide
  install base, works on Apple Silicon (M1–M4) on current macOS.
- **NTFS-3G**: the mature, GPLv2-licensed, actively maintained (upstream
  2026.2.25 release confirmed during research) userspace NTFS driver. It is
  the same code family used by nearly every "write to NTFS on Mac" free
  solution for over a decade. Runs entirely as a userspace process on top of
  the FUSE API — it never touches the partition table and cannot format or
  repartition a disk; its own safety mechanisms already refuse to mount a
  volume flagged dirty/hibernated unless the caller explicitly forces it
  (which this app never does).
- **Decision: this is the v1 backend.** It is the only candidate that is
  simultaneously (a) fully open-source at the filesystem-driver layer, (b)
  proven in production for years across Intel and Apple Silicon, (c) free of
  any requirement to touch SIP, kexts, or the partition table, and (d) not
  blocked by an unresolved platform bug.

## 3. Backend comparison matrix

| | In-box (RO) | FSKit NTFS (3rd-party) | FUSE-T + NTFS-3G | macFUSE + NTFS-3G |
|---|---|---|---|---|
| Apple Silicon | Yes | Yes | Yes | Yes |
| macOS 14/15/26 | Yes | 15.4+/26 only | Yes | Yes |
| Kernel extension | No | No | No | No (system extension, no kext) |
| SIP changes | None | None | None | None |
| Root required | No | No | For device mount | For device mount (via helper) |
| Write support | **No** | Blocked by OS bug on physical disks | Yes | Yes |
| Bundling license | N/A | N/A | Commercial license needed to embed | Driver framework open; ext. is free redistributable freeware; NTFS-3G is GPLv2 |
| Maturity (2026) | Ships with OS | New, unresolved bug | Mature | Mature, most widely deployed |
| **Chosen for v1** | Fallback/inform | No (future) | No (documented alt.) | **Yes** |

## 4. What this means concretely

- **No filesystem modification**: mounting/unmounting through NTFS-3G touches
  only the FUSE mount table and the NTFS journal/metadata exactly as any NTFS
  write operation legitimately would — the same code path Windows itself uses
  conceptually. The app never runs `diskutil eraseVolume`, `diskutil
  partitionDisk`, `newfsstat`, or any formatting/partitioning command. Those
  commands do not exist anywhere in this codebase (see `docs/SECURITY.md`).
- **No SIP changes**: never required, never requested, never suggested to the
  user.
- **Root privileges**: mounting a block device with a FUSE filesystem
  requires opening the raw device node, which is root-owned. Mountly
  isolates *all* privileged work behind a minimal, allow-listed XPC
  helper (`MountlyHelperTool`, see §7) installed via `SMAppService.daemon`
  — never a raw shell, never `AuthorizationExecuteWithPrivileges`, never a
  stored credential.
- **Dependency installation**: macFUSE + NTFS-3G cannot legally/technically
  be embedded as silently-loaded code inside our sandboxed `.app` bundle
  (system extensions must be user-approved, and NTFS-3G's GPLv2 license and
  macFUSE's freeware-extension license are both best served by installing
  the *upstream, officially signed and notarized* installers rather than us
  re-packaging their binaries). Mountly instead ships a polished
  first-run **BackendInstaller** flow (see §8) that detects, downloads
  (from the official macFUSE and NTFS-3G release channels, over HTTPS, with
  checksum verification), and explains the one-time System Settings approval
  step. The user is never asked to open Terminal.

## 5. App Sandbox decision

**App Sandbox is disabled**, and this is a deliberate, documented exception
(see also `docs/SECURITY.md` §"Why not App Sandbox"):

- The app must invoke `mount_ntfs-3g` / `ntfs-3g` against arbitrary external
  block devices via a privileged helper — sandboxed apps cannot install or
  talk to an arbitrary launchd daemon of their own choosing outside the
  sandbox's XPC/service model in the way a disk-utility class app requires.
- The app must read Disk Arbitration state for *any* attached disk (not just
  files the user opened via a picker), which is fundamentally an
  administration/utility capability, not a sandboxed-document-app capability.
- Hardened Runtime **is** enabled (required for notarization) and the app
  requests only the specific entitlements it needs
  (`com.apple.security.cs.disable-library-validation` is *not* requested;
  no entitlement disables SIP or kernel protections).

## 6. Backend abstraction

```
FilesystemBackend (protocol)
 ├─ detect(disk) -> FilesystemKind?
 ├─ mount(disk, mode) -> MountResult
 ├─ unmount(mountPoint) -> Void
 ├─ verifyRead(mountPoint) -> Bool
 ├─ verifyWrite(mountPoint) -> Bool
 ├─ status(mountPoint) -> BackendStatus
 └─ diagnostics() -> BackendDiagnostics
```

The rest of the app (UI, `MountManager`, `TransferManager`, `EjectManager`)
depends only on `FilesystemBackend`, `BackendRegistry`, `Drive`, and
`DriveState` — never on a specific backend, macFUSE, or NTFS-3G directly.
This is what makes it possible to add a backend for a new filesystem
without touching UI code. See
`Sources/MountlyCore/Filesystem/FilesystemBackend.swift`.

### 6.1 Registered backends (manufacturer-agnostic, filesystem-keyed)

`BackendRegistry.default` (`Sources/MountlyCore/Filesystem/BackendRegistry.swift`)
maps `FilesystemKind -> FilesystemBackend`. Detection is entirely by
filesystem type (`DriveDetectionService` reads Disk Arbitration's volume
kind), never by manufacturer string — the same code path handles a
Transcend, Samsung, SanDisk, WD, Seagate, or completely generic/no-name
external drive identically, because none of it is manufacturer-specific.

| Filesystem | Backend | Why |
|---|---|---|
| NTFS | `NTFSBackend` | Third-party driver (macFUSE + NTFS-3G, §2.4) — macOS has no native write support. |
| exFAT, FAT32, APFS, HFS+ | `NativeReadWriteBackend` | macOS already mounts these read/write natively; this backend only *observes and verifies* the mount macOS made — no privileged helper, no system extension, no third-party code at all. Implementing yet another driver for filesystems Apple already handles would be needless risk (§4 "no filesystem modification" spirit extends here). |
| ext4 (and ext2/ext3) | *(unregistered)* | There is no safe, actively-maintained, native-feeling macOS ext4 read/write driver to wrap responsibly in 2026. `BackendRegistry` has no entry for it on purpose — the UI shows "Detected — Limited Support" rather than a fake "Read & Write." Revisit only if a genuinely safe option emerges; never implement an ext4 driver from scratch merely to claim support. |
| Unknown/unrecognized | *(unregistered)* | Same reasoning — surfaced honestly, never guessed at. |

`NativeReadWriteBackend.unmount` calls unprivileged `diskutil eject`
directly (Mountly never privilegedly mounted these, so there's nothing to
route through the helper); `NTFSBackend.unmount` still goes through
`HelperClient`/`MountlyHelperTool`, since that's the same privileged path
that mounted it. Both backends share one write-verification routine,
`Sources/MountlyCore/Filesystem/WriteProbe.swift` — a single, tested
implementation of "create → read back → delete → confirm gone" that every
backend uses before ever claiming write access, so that guarantee isn't
duplicated (and can't drift) across backends.

### 6.2 Auto-verification vs. explicit opt-in

exFAT/FAT32/APFS/HFS+ never need the user to click "Enable Write Access" —
`AppState` (`Sources/Mountly/App/AppState.swift`) quietly runs the same
write-verification probe the moment such a drive is detected mounted, and
promotes it straight to "Read & Write" if it passes, silently leaving it
at "Read Only" if not (e.g. a locked SD card) — no error, no interruption.
NTFS deliberately stays an explicit user action, because unlike the native
filesystems it requires a one-time backend install and a privileged mount
the user should consciously request; automatic
mounting defaults off until proven safe end to end for a given user.

## 7. Privileged helper design

`MountlyHelperTool` is a small, separately-signed executable embedded at
`Contents/Library/LaunchDaemons/com.mountly.app.helper`, registered
via `SMAppService.daemon(plistName:)` (the current Apple-recommended
replacement for the deprecated `SMJobBless`/`AuthorizationExecuteWithPrivileges`
APIs). It exposes exactly **four** operations over a Mach-service XPC
connection, each independently validated:

1. `mountNTFS(bsdName:mountPoint:readOnly:)` — refuses unless Disk
   Arbitration confirms `bsdName` is (a) currently attached, (b) external,
   (c) NTFS, (d) not the boot volume, (e) not an internal disk.
2. `unmount(mountPoint:)` — refuses to unmount anything outside `/Volumes`.
3. `status(bsdName:)` — read-only.
4. `killMountProcess(mountPoint:)` — used only as part of the safe-eject
   path after a transfer is confirmed stopped.

There is no "run arbitrary command" method, no shell string interpolation
(`ProcessRunner` always takes an argument array, never a shell string — see
`Sources/MountlyCore/Utilities/ProcessRunner.swift`), and no
persistent credential storage. The helper logs to the unified logging system
(never file contents, never credentials) and exits promptly; it holds no
long-lived state beyond what launchd gives it.

## 8. Dependency installation flow (`BackendInstaller`)

1. Detect: is `macFUSE.framework`/the macFUSE system extension present
   (`/Library/Filesystems/macfuse.fs`, or `systemextensionsctl list`)? Is
   `ntfs-3g` present at a known path?
2. If both present and functional → proceed straight to mounting.
3. If missing → show the "One more step" screen (see UI spec, main app
   README), explain exactly what will be downloaded and why, then:
   - Download the official macFUSE installer package from the macFUSE GitHub
     Releases (pinned, versioned URL), verify its SHA-256 against a checksum
     recorded in `BackendInstaller` at release time, and hand off to
     `installer`/the pkg's own signed, notarized flow — Mountly
     never re-signs or repackages a third-party installer.
   - Explain that macOS will ask for one-time approval of a system extension
     in Privacy & Security, and why (Apple requires this for *any* app that
     installs a system extension — it is not something this app can or
     should bypass).
   - Build/obtain `ntfs-3g` from its official source distribution.
4. Verify installation succeeded before declaring the backend ready.
5. Never retries silently forever; surfaces a clear error after one failed
   attempt.

**Confirmed limitation, and its fix (2026-09-06, verified directly on this
development machine):** mainline Homebrew's own `ntfs-3g` formula is now
**Linux-only** — `brew install ntfs-3g` fails outright with `ntfs-3g: Linux
is required for this software`, and `brew install --build-from-source
ntfs-3g` fails the same way. Homebrew's own core formula is not a viable
path on macOS at all in 2026, regardless of bottles.

The real, currently-working path — confirmed by actually tapping and
resolving it — is the community-maintained **`gromgit/fuse` tap's
`ntfs-3g-mac` formula** (`brew tap gromgit/fuse && brew install
gromgit/fuse/ntfs-3g-mac`), which:
- ships real pre-built bottles for this exact configuration (`arm64_tahoe`
  and `arm64_sequoia` were both present when checked),
- declares `depends_on MacfuseRequirement` — i.e. it is *designed* around
  the macFUSE-first install order this app already uses,
- installs the standard `ntfs-3g`/`mkntfs`/`ntfsfix`/`ntfslabel` binaries at
  the normal Homebrew `bin`/`sbin` paths `NTFSBackend` already looks for, so
  no path-detection changes were needed once the correct formula is used,
- and ships its own generated mount wrapper whose option set
  (`negative_vncache,auto_xattr,auto_cache,noatime,windows_names,
  streams_interface=openxattr,inherit,uid=…,gid=…,allow_other,big_writes`)
  is community-vetted; `MountlyHelperTool`'s own `mountNTFS` adopts the
  same option set, with `uid`/`gid` mapped to the logged-in console user
  (via `/dev/console`'s owner) so files created from Finder are user-owned
  rather than root-owned, since the helper itself runs as root.

`BackendInstaller.installNTFS3G` taps `gromgit/fuse` and installs
`gromgit/fuse/ntfs-3g-mac` accordingly. This is documented here, rather than
silently assumed, because it is exactly the kind of ecosystem-fragility
this architecture doc exists to surface before it becomes a support
nightmare: the "obvious" `brew install ntfs-3g` command that appears in
older tutorials no longer works on macOS at all.

## 9. Mounting / unmounting / Finder integration

- **Mounting**: Disk Arbitration reports a new NTFS partition → app shows a
  card in "Detected" state → user (or, if enabled, automatic policy) chooses
  to mount read/write → `MountManager` asks `MountlyHelperTool` to unmount
  the existing Apple read-only auto-mount (if any) and mount via NTFS-3G at
  `/Volumes/<VolumeName>` → `MountManager` performs a **non-destructive write
  probe** (create → verify exists → read back → delete → verify gone) before
  ever reporting "Write access verified" in the UI.
- **Unmounting/Ejecting**: `EjectManager` refuses to eject while
  `TransferManager` reports in-flight transfers; offers **Wait** or **Cancel
  Transfer**, never a forced default eject.
- **Finder**: once mounted, the volume appears in `/Volumes` like any other
  disk — Finder, `NSWorkspace.shared.open(mountURL)`, and every standard
  Finder operation (copy, rename, delete, get info) work against it exactly
  as they would against any mounted volume. Mountly does not
  reimplement file management; it opens Finder at the mount point and
  additionally offers first-class copy/rename/delete/new-folder actions of
  its own via `FileManager`, for users who prefer to stay inside the app.

## 10. Failure scenarios & recovery

| Scenario | Detection | Recovery |
|---|---|---|
| Backend not installed | `BackendInstaller.detect()` | Offer install flow; never proceed to mount |
| Windows hibernation / Fast Startup / dirty volume | NTFS-3G reports "Volume is scheduled for a check" / hibernated flag on mount attempt | Never force; offer **Mount Read Only** + **Learn More**; no repair operation exists in this app |
| Mount succeeds but write probe fails | Explicit probe step in `MountManager` | Unmount back to a known-safe state, report exact reason, never claim writable |
| Drive removed mid-transfer | Disk Arbitration disappearance callback + I/O error from `TransferManager` | Cancel transfer, mark drive "Not Connected", no crash, no repeated retry storm |
| Stale mount from a previous crash/quit | App launch check: is `/Volumes/<name>` still using our helper's mount, but the app has no record of it? | Verify via `status()`, offer to detach cleanly; never assume and never force-unmount blindly |
| Backend crashes/hangs | XPC connection invalidation callback | Surface error, do not retry indefinitely (max 1 automatic retry) |

## 11. Licensing implications (summary — full detail in `THIRD_PARTY_LICENSES.md`)

- **NTFS-3G**: GPLv2. Not statically linked into our binary; invoked as a
  separate process installed by its own official installer. No GPL
  obligations are triggered by *invoking* an independently-installed GPL
  program via `Process`, the same way invoking `/usr/bin/tar` does not
  GPL-encumber the caller.
- **macFUSE**: system-extension binary is free, closed-source; the
  `macFUSE.framework` companion library, if ever linked directly, carries a
  BSD/APSL-style license for the portions we would use. v1 does not link
  macFUSE.framework directly — it shells out to the installed `mount_macfuse`
  toolchain the official installer provides, for the same reason as above.
- Neither dependency is bundled inside `Mountly.app`; both are
  installed via their own official, independently signed/notarized
  installers, which sidesteps redistribution-license questions entirely.

## 12. Conclusion

macFUSE + NTFS-3G is selected as the v1 `FilesystemBackend`. It is the only
option with no unresolved platform blocker, no bundling-license conflict, no
SIP/kext requirement, and years of production use on the exact drive class
(external NTFS SSDs) this app targets. FSKit is documented as the intended
future backend once Apple's third-party NTFS masking issue is resolved
upstream; the backend abstraction in §6 makes that a swap, not a rewrite.
