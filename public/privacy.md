# Mountly Privacy Policy

Effective: September 2026 · Universal macOS Utility · 100% Offline

Mountly is designed from first principles to be completely local, private, and transparent. We never track you, collect data, or connect to external servers.

## Core principles

- **Zero Network Activity**: No telemetry beacons, analytics pings, or background server calls. Mountly functions completely severed from the internet.
- **Apple DiskArbitration**: Mounting and partition detection rely directly on official Apple frameworks without unsafe kernel modifications.
- **Zero File Inspection**: Mountly never catalogs, reads, or indexes contents on your storage devices. Discovered volumes open directly in Finder.

## 01. Information Collection & Storage

Mountly does not collect, record, transmit, or monetize any personal information or telemetry data. Specifically:

- No user identities or account info
- No unique hardware identifiers
- No session logs or launch counters
- No IP addresses or location data

## 02. Drive Management & File Content Isolation

When you connect an external USB-C, USB-A, portable SSD, or mechanical hard drive, Mountly inspects only the partition header metadata required to recognize the filesystem type (e.g., NTFS, exFAT, APFS).

At no point does Mountly scan, index, copy, or transmit directory listings or personal documents stored on your drive. All read and write operations are routed through standard macOS filesystem drivers directly to Finder.

## 03. System Permissions & Helper Privileges

Mounting non-native external filesystems (such as enabling NTFS write mode) may require administrative disk arbitration authorization via macOS Security prompts.

Privileges are confined strictly to standard disk mount/unmount operations and safe volume synchronization. Mountly never requests root access to personal user folders or keychain items.

## 04. Website & Download Integrity

This website is delivered as static HTML, JavaScript, and CSS. No advertising networks, marketing trackers, or tracking cookies are employed on this domain. Downloads are verified and hosted directly without third-party ad-wrappers or data capture intermediaries.

## 05. Open Source Verification & Auditing

Trust is established through verifiability. The complete source code of Mountly is maintained openly on GitHub. Anyone can audit the network entitlements, inspect disk helpers, and compile the code independently.

- [Inspect Source on GitHub](https://github.com/kolapoimam/mountly)
- [Developer Portfolio](https://kolapo.ng)

## Privacy Questions & Answers

### Does Mountly ever transmit disk names or serial numbers?
No. Device descriptors, volume labels, and filesystem partition tables are queried strictly in-memory using Apple DiskArbitration and are discarded upon eject or app termination.

### Does Mountly send crash reports or analytics?
No. Mountly contains zero crash analytics SDKs, zero telemetry probes, and no marketing tags. If an error occurs during disk mounting, diagnostic messages are sent solely to your local macOS Console.

### Can Mountly read or index files on my mounted drives?
No. Mountly operates as a mounting controller, not a file indexer. Once a drive is mounted, your file operations are handled directly by macOS Finder and your chosen applications.

### How can I verify these privacy claims?
Mountly is open source. You can inspect the source code, examine the project’s network entitlements, and build the binary directly from GitHub.

---

[Back to Mountly](https://mountlyapp.vercel.app/)
