# Security Model

Mountly exists to add read/write access to an NTFS volume the
user already trusts with important files. Every design decision here is
weighed against one question: *could this put that data at risk?* When
uncertain, the answer this codebase gives is always the non-destructive
one.

## What privileged operations exist, and why

The **only** privileged (root-requiring) operations in the entire app are
the four methods on `HelperXPCProtocol`, implemented by
`MountlyHelperTool` and installed via `SMAppService.daemon`:

1. `mountNTFS(bsdName:mountPoint:readOnly:)` — mounting a block device
   requires opening its raw device node, which is root-owned on macOS.
2. `unmount(mountPoint:)` — unmounting a volume the helper mounted.
3. `status(mountPoint:)` — read-only.
4. `ping(...)` — liveness/version check.

There is no fifth method. There is no "run arbitrary command" escape
hatch. `ProcessRunner` (`Sources/MountlyCore/Utilities/ProcessRunner.swift`)
never builds a shell string — every invocation is `executable + [String]`
argument array, so there is nowhere in this codebase that shell-injects
caller- or filesystem-derived text.

The helper **re-derives and re-validates every request itself** — it does
not trust the app's word for anything:
- `diskutil info` is queried fresh for the given BSD name.
- The disk must not be `internal` (refuses `.internalDiskRefused`).
- The reported filesystem must actually be NTFS (refuses `.notNTFS`).
- The requested mount point must be under `/Volumes/` (refuses anything
  else, including any path that could target `/`, `/System`, or a user's
  home directory).
- The connecting XPC client's code signature must carry the **same Team
  ID as the helper's own signature** (`ClientValidator` in
  `Sources/MountlyHelperTool/main.swift`, using `SecCodeCopyGuestWithAttributes`
  + `SecCodeCheckValidity`) — a process that isn't signed by whoever signed
  this exact build of Mountly cannot talk to the helper at all.
  If the helper's own signing identity can't be determined (e.g. an
  unsigned local debug build), the check **fails closed**, not open.

## What Mountly never does

Every item below is a hard rule, not a preference — none of the following
commands or capabilities appear anywhere in this codebase:

- Format, erase, or repartition a disk (`diskutil eraseVolume`,
  `eraseDisk`, `partitionDisk`, `apfs` volume-erase verbs — none are
  referenced).
- Convert NTFS to any other filesystem.
- Automatically initialize an uninitialized/unformatted disk.
- Modify the partition table (GPT/MBR) in any way.
- Run `fsck`/`ntfsfix` in a repair/write mode, or any filesystem-repair
  operation at all — a dirty/hibernated volume is only ever offered
  **read-only** mounting plus an explanation (see `docs/TROUBLESHOOTING.md`).
- Delete a user's file without an explicit, specific confirmation for that
  file (see `DriveCardView`'s conflict/delete flows).
- Change a volume's UUID or label without the user explicitly renaming it
  via a normal Finder-equivalent rename action.
- Disable SIP, or ask the user to. Nothing in this app touches
  `csrutil`, boot arguments, or Recovery Mode.
- Replace `/sbin/mount_ntfs` or any other Apple system binary.
- Modify `/etc/fstab`.
- Install an undocumented persistent service — the only installed daemon
  is `MountlyHelperTool`, registered exactly once via the standard,
  auditable `SMAppService.daemon` API, with its launchd plist shipped
  inside the app bundle for anyone to inspect.
- Silently execute anything as root without going through the helper's
  four validated methods above.

## Write access is verified, never assumed

`NTFSBackend.mount(mode: .readWrite)` never reports success on the mount
command's exit code alone. After mounting, it runs a **non-destructive
write probe**: create a uniquely-named hidden file → confirm it exists →
read it back and compare bytes → delete it → confirm it's gone. Only if
every step succeeds does the UI show "Write access verified." If any step
fails, `NTFSBackend` unmounts back to a known-safe state and reports
`TMError.writeVerificationFailed` — it never leaves the drive in an
ambiguous "maybe writable" state.

## Why App Sandbox is disabled

This is a deliberate, documented exception, not an oversight:

- The app must install and talk to a privileged `launchd` daemon of its
  own choosing (`MountlyHelperTool`) — outside what App Sandbox's XPC
  service model supports for a disk-utility-class app.
- The app must observe Disk Arbitration state for *any* attached disk, not
  just a file the user picked via `NSOpenPanel` — a fundamentally
  system-administration capability.
- Hardened Runtime **is** enabled (required for notarization). No
  entitlement in `Resources/Mountly.entitlements` or
  `Resources/MountlyHelperTool.entitlements` disables library
  validation, disables SIP, or weakens kernel-level protections.

## Privacy

- No cloud account, no analytics, no telemetry — in this version or any
  planned one. `EventLog` and the unified-logging categories in
  `Utilities/Logger.swift` never record file contents, credentials, or
  other personal data — only operational events (e.g. "mounted disk4s1",
  never the names or contents of files on it).
- Network access is limited to exactly two purposes, both user-initiated:
  downloading the pinned, checksum-verified macFUSE installer, and running
  `brew install` for NTFS-3G. Mountly never uploads drive
  contents anywhere.

## Credentials

Mountly never shows a custom password field and never stores a
credential. The two places privilege is required are handled entirely by
Apple's or Homebrew's own mechanisms:
- macFUSE's `.pkg` installer is opened via `NSWorkspace.shared.open(...)`,
  so **Apple's own `installer` authorization dialog** handles admin
  approval — Mountly never sees the password.
- `MountlyHelperTool` registration goes through `SMAppService`, which
  uses the standard system consent UI, not a custom prompt.
