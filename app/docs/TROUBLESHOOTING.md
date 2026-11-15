# Troubleshooting

## "Drive appears but is read-only"

This is expected the moment you connect an NTFS drive — macOS's own
built-in driver always mounts NTFS read-only. Click **Enable Write
Access** on the drive's card. Mountly will mount it via NTFS-3G
and run a write test before calling it writable; if that succeeds you'll
see "Read & Write" and a green checklist.

## "NTFS backend unavailable" / "Set Up" screen

Mountly needs two small, open-source components:

- **macFUSE** — lets macOS run filesystem drivers in user space, with no
  kernel extension. Installed from its official, checksum-verified DMG;
  you'll approve a system extension once in **System Settings → Privacy &
  Security**. This is Apple's own approval step and cannot be skipped by
  any app.
- **NTFS-3G** — the actual read/write NTFS driver. Installed via Homebrew.

If you prefer to do this yourself in Terminal:

```bash
brew install --cask macfuse
brew tap gromgit/fuse
brew install gromgit/fuse/ntfs-3g-mac
```

Do **not** run `brew install ntfs-3g` (no tap) — as of 2026, mainline
Homebrew's own `ntfs-3g` formula is Linux-only and will fail with `Linux
is required for this software`. This is a real upstream packaging
decision, not a Mountly bug.

If `gromgit/fuse/ntfs-3g-mac` reports "no bottle available" for your
specific macOS version, Mountly surfaces
`BackendInstaller.InstallerError.noPrebuiltPackageAvailable` rather than
silently compiling it (which needs Xcode Command Line Tools and several
minutes). You can accept that trade-off yourself with `brew install
--build-from-source gromgit/fuse/ntfs-3g-mac`.

## "Volume appears unsafe" / "Windows Hibernation Detected" / "Dirty Filesystem"

NTFS-3G refused to mount read/write because the volume's internal journal
looks inconsistent — usually because Windows used Fast Startup/hibernation
instead of a full shutdown, or the drive was unplugged without ejecting.
Mountly will **never** force a write mount in this state and has
no repair operation. Options offered:

- **Mount Read Only** — safe, lets you read files immediately.
- **Learn More** — explains the specific risk.

To resolve it: connect the drive to a Windows PC, fully shut the PC down
(not sleep, and with Fast Startup disabled if you want to be certain),
then reconnect it to your Mac.

## "Mountly needs one-time approval to enable write access" / raw `connectionFailed`

Mountly's NTFS mounting goes through a small privileged helper
(`MountlyHelperTool`), registered with macOS via `SMAppService`. The first
time you enable write access on any NTFS drive, macOS requires you to
approve that helper once in **System Settings → General → Login Items &
Extensions** (look for Mountly under "Allow in the Background") — clicking
**Open System Settings** on this error takes you straight there. Approve
it, come back, and click **Try Again**. If you see a bare `connectionFailed`
in Technical Details instead of this friendlier message, you're on an
older build — update to the latest Mountly, which detects this specific
condition and explains it rather than surfacing the raw XPC error.

## "Mount failed"

Shown with a plain-language reason, an explanation, and a **Copy Technical
Details** button (never a bare exit code as the headline — see
`docs/SECURITY.md`/`TMError`). Common causes:
- The backend components aren't fully installed yet (see above).
- The privileged helper isn't approved yet — see the section just above.
- Another process (Finder, Terminal) has the device busy — quit anything
  else that might be using the drive and try again.
- The system extension for macFUSE hasn't been approved yet in Privacy &
  Security.

## "Drive disappeared"

The drive was physically disconnected, lost power, or was unmounted from
outside Mountly (e.g. via Finder or `diskutil` in Terminal).
Mountly detects this immediately via Disk Arbitration, cancels
any in-flight transfers, and returns the drive card to "Not Connected" —
it does not keep retrying or hang.

## Uninstalling macFUSE / NTFS-3G separately

- macFUSE: see its own uninstaller instructions at
  https://osxfuse.github.io (Mountly does not install a
  privileged component of its own for macFUSE — it hands off to macFUSE's
  official installer, so removal goes through macFUSE's own process too).
- NTFS-3G: `brew uninstall gromgit/fuse/ntfs-3g-mac`

`Scripts/uninstall.sh` removes Mountly itself but deliberately
leaves both of the above in place, since other software you use may also
depend on them.
