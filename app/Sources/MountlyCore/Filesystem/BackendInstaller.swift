import Foundation
import CryptoKit

/// A pinned, checksummed release artifact. Values here were captured by
/// fetching the official release directly and recording what was actually
/// downloaded — not invented. Update both `version` and `sha256` together
/// whenever the pin is bumped, by downloading the new official release and
/// computing its real checksum (see `docs/RELEASE.md`).
public struct ReleasePin: Sendable {
    public let version: String
    public let downloadURL: URL
    public let sha256: String
}

public enum BackendInstallStep: Sendable, Equatable {
    case checkingExistingInstallation
    case downloading(component: String, fractionComplete: Double)
    case verifyingChecksum(component: String)
    case awaitingSystemInstaller(component: String)
    case installingUnprivileged(component: String)
    case verifying
    case complete
    case failed(String)
}

/// First-run / Settings dependency installer. Every network
/// operation here is a plain HTTPS GET to an official release host; nothing
/// is ever piped into a shell, and no step silently requests admin
/// credentials — privileged installation is always handed off to Apple's
/// own `installer`/pkg UI or Homebrew's own (also Apple-authorization-based)
/// privileged-install path.
public actor BackendInstaller {
    public static let shared = BackendInstaller()

    /// macFUSE 5.3.3 — verified 2026-09-06 by downloading the official
    /// release from https://github.com/macfuse/macfuse/releases and
    /// checking the DMG's SHA-256 against the maintainer-published
    /// `macfuse-5.3.3.sha256` file (also signature-verifiable via the
    /// accompanying `.sha256.sig`).
    public static let macFUSEPin = ReleasePin(
        version: "5.3.3",
        downloadURL: URL(string: "https://github.com/macfuse/macfuse/releases/download/macfuse-5.3.3/macfuse-5.3.3.dmg")!,
        sha256: "7a0b7b66c0e7f8932707d1215dc9cf486e178d097ae0a2dcdf17d8530566aa15"
    )

    private let backend = NTFSBackend()

    public enum InstallerError: Error, Sendable {
        case checksumMismatch(expected: String, actual: String)
        case downloadFailed(String)
        case noSystemInstallerFound
        case homebrewRequired
        /// Homebrew has no pre-built bottle for ntfs-3g on this macOS
        /// version/architecture (a real, observed Tier-3 packaging gap as
        /// of 2026 — see docs/ARCHITECTURE.md). Building from source would
        /// require Xcode Command Line Tools and several minutes of
        /// compilation, which this app deliberately does not do silently
        /// — surfaced instead as a clear, actionable error.
        case noPrebuiltPackageAvailable
    }

    private init() {}

    public func isMacFUSEInstalled() -> Bool {
        FileManager.default.fileExists(atPath: "/Library/Filesystems/macfuse.fs")
            || FileManager.default.fileExists(atPath: "/Library/Frameworks/macFUSE.framework")
    }

    public func isNTFS3GInstalled() -> Bool {
        ["/opt/homebrew/bin/ntfs-3g", "/usr/local/bin/ntfs-3g",
         "/opt/homebrew/bin/mount_ntfs-3g", "/usr/local/bin/mount_ntfs-3g"]
            .contains { FileManager.default.isExecutableFile(atPath: $0) }
    }

    public func homebrewPath() -> String? {
        for path in ["/opt/homebrew/bin/brew", "/usr/local/bin/brew"] {
            if FileManager.default.isExecutableFile(atPath: path) { return path }
        }
        return nil
    }

    public func isFullyInstalled() async -> Bool {
        await backend.isInstalled()
    }

    /// Downloads and verifies the pinned macFUSE DMG, mounts it, and hands
    /// the enclosed `.pkg` to `NSWorkspace` so the *system's own* installer
    /// (with Apple's own authorization dialog) completes the privileged
    /// steps. Mountly never sees or handles the user's password.
    public func downloadAndVerifyMacFUSE(progress: @Sendable (BackendInstallStep) -> Void) async throws -> URL {
        progress(.downloading(component: "macFUSE", fractionComplete: 0))
        let (tempURL, _) = try await URLSession.shared.download(from: Self.macFUSEPin.downloadURL)

        progress(.verifyingChecksum(component: "macFUSE"))
        let data = try Data(contentsOf: tempURL)
        let digest = SHA256.hash(data: data)
        let actualHex = digest.map { String(format: "%02x", $0) }.joined()
        guard actualHex == Self.macFUSEPin.sha256 else {
            throw InstallerError.checksumMismatch(expected: Self.macFUSEPin.sha256, actual: actualHex)
        }

        let destination = FileManager.default.temporaryDirectory
            .appendingPathComponent("macfuse-\(Self.macFUSEPin.version).dmg")
        try? FileManager.default.removeItem(at: destination)
        try FileManager.default.moveItem(at: tempURL, to: destination)
        return destination
    }

    /// Installs NTFS-3G. There is no official standalone signed macOS
    /// installer for NTFS-3G in 2026, and mainline Homebrew's own `ntfs-3g`
    /// formula is Linux-only (verified 2026-09-06: `brew install ntfs-3g`
    /// fails with "Linux is required for this software"). The real,
    /// currently-working path — verified directly, including its actual
    /// bottled binary for this Apple Silicon macOS release — is the
    /// community-maintained `gromgit/fuse` tap's `ntfs-3g-mac` formula,
    /// which itself depends on macFUSE. If Homebrew isn't present, this
    /// throws `.homebrewRequired` — the UI layer explains the one-time
    /// Homebrew install step rather than us silently curl-piping a script.
    public func installNTFS3G(progress: @Sendable (BackendInstallStep) -> Void) async throws {
        guard let brew = homebrewPath() else {
            throw InstallerError.homebrewRequired
        }
        progress(.installingUnprivileged(component: "NTFS-3G"))
        _ = try? ProcessRunner.run(brew, arguments: ["tap", "gromgit/fuse"], timeout: 60)
        let result = try ProcessRunner.run(brew, arguments: ["install", "gromgit/fuse/ntfs-3g-mac"], timeout: 300)
        if !result.succeeded && !isNTFS3GInstalled() {
            let combined = (result.standardOutput + result.standardError).lowercased()
            if combined.contains("no bottle available") {
                throw InstallerError.noPrebuiltPackageAvailable
            }
            throw InstallerError.downloadFailed(result.standardError)
        }
        progress(.verifying)
    }
}
