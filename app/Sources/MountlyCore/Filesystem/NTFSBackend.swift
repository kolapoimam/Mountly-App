import Foundation

/// The v1 `FilesystemBackend` conformer, selected in `docs/ARCHITECTURE.md`.
/// Mounts NTFS volumes via macFUSE + NTFS-3G through the privileged helper,
/// and never claims write access without actually testing it.
public struct NTFSBackend: FilesystemBackend {
    public let name = "macFUSE + NTFS-3G"
    public let supportedFilesystem: FilesystemKind = .ntfs

    private static let candidateBinaryDirs = [
        "/opt/homebrew/bin", "/opt/homebrew/sbin",
        "/usr/local/bin", "/usr/local/sbin"
    ]

    private static let macFUSEMarkerPaths = [
        "/Library/Filesystems/macfuse.fs",
        "/Library/Frameworks/macFUSE.framework"
    ]

    public init() {}

    private func findBinary(_ name: String) -> String? {
        for dir in Self.candidateBinaryDirs {
            let path = dir + "/" + name
            if FileManager.default.isExecutableFile(atPath: path) {
                return path
            }
        }
        return nil
    }

    public func isInstalled() async -> Bool {
        let hasMacFUSE = Self.macFUSEMarkerPaths.contains { FileManager.default.fileExists(atPath: $0) }
        let hasNTFS3G = findBinary("ntfs-3g") != nil || findBinary("mount_ntfs-3g") != nil
        return hasMacFUSE && hasNTFS3G
    }

    public func mount(bsdName: String, mode: MountMode) async throws -> MountResult {
        guard await isInstalled() else {
            throw TMError.backendNotInstalled
        }

        let info = try DiskUtility.info(forBSDName: bsdName)
        guard !info.internalDisk else { throw TMError.internalDiskRefused }
        let filesystem = FilesystemKind(diskArbitrationFilesystemName: info.filesystemName ?? "")
        guard filesystem == .ntfs else { throw TMError.unexpectedFilesystem(actual: filesystem) }

        let volumeName = info.volumeName ?? bsdName
        let mountPoint = URL(fileURLWithPath: "/Volumes/\(volumeName)")

        await EventLog.shared.record("Mounting \(bsdName) at \(mountPoint.path), mode=\(mode)", category: .filesystemBackend)

        // The privileged helper must be registered with launchd before any
        // XPC connection to it can succeed at all — see HelperRegistrar.
        switch HelperRegistrar.registerIfNeeded() {
        case .alreadyRegistered, .registered:
            break
        case .requiresApproval:
            throw TMError.helperApprovalRequired
        case .failed(let detail):
            throw TMError.mountFailed(technicalDetail: "helper registration failed: \(detail)")
        }

        do {
            try await HelperClient.shared.mountNTFS(
                bsdName: bsdName,
                mountPoint: mountPoint.path,
                readOnly: mode == .readOnly
            )
        } catch {
            // If the connection still failed after confirming registration,
            // re-check status — the user may have revoked approval, or
            // launchd hasn't caught up yet — and surface the specific,
            // actionable reason instead of a generic "mount failed."
            if HelperRegistrar.currentStatus() == .requiresApproval {
                throw TMError.helperApprovalRequired
            }
            throw TMError.mountFailed(technicalDetail: String(describing: error))
        }

        guard await verifyRead(mountPoint: mountPoint) else {
            try? await unmount(mountPoint: mountPoint)
            throw TMError.mountFailed(technicalDetail: "post-mount read check failed")
        }

        var writeVerified = false
        if mode == .readWrite {
            writeVerified = await verifyWrite(mountPoint: mountPoint)
            if !writeVerified {
                await EventLog.shared.record("Write verification failed for \(mountPoint.path); returning to unmounted state", category: .security)
                try? await unmount(mountPoint: mountPoint)
                throw TMError.writeVerificationFailed(technicalDetail: "write probe did not complete successfully")
            }
        }

        return MountResult(mountPoint: mountPoint, mode: mode, writeVerified: writeVerified)
    }

    public func unmount(mountPoint: URL) async throws {
        guard mountPoint.path.hasPrefix("/Volumes/") else {
            throw TMError.unmountFailed(technicalDetail: "refusing to unmount a path outside /Volumes")
        }
        do {
            try await HelperClient.shared.unmount(mountPoint: mountPoint.path)
        } catch {
            throw TMError.unmountFailed(technicalDetail: String(describing: error))
        }
    }

    public func verifyRead(mountPoint: URL) async -> Bool {
        WriteProbe.verifyRead(mountPoint: mountPoint)
    }

    /// Non-destructive write probe — only ever runs after the
    /// user explicitly requested read/write mounting.
    public func verifyWrite(mountPoint: URL) async -> Bool {
        WriteProbe.verifyWrite(mountPoint: mountPoint)
    }

    public func status(mountPoint: URL) async -> BackendStatus {
        let mounted = await HelperClient.shared.status(mountPoint: mountPoint.path)
        guard mounted else { return .notMounted }
        let writable = await verifyWrite(mountPoint: mountPoint)
        return BackendStatus(
            isMounted: true,
            mountPoint: mountPoint,
            mode: writable ? .readWrite : .readOnly,
            writeVerified: writable
        )
    }

    public func diagnostics() async -> BackendDiagnostics {
        var versions: [String: String] = [:]
        var notes: [String] = []

        if let ntfs3g = findBinary("ntfs-3g") {
            if let result = try? ProcessRunner.run(ntfs3g, arguments: ["--version"]) {
                versions["ntfs-3g"] = (result.standardOutput + result.standardError)
                    .split(separator: "\n").first.map(String.init) ?? "unknown"
            }
        } else {
            notes.append("ntfs-3g binary not found in \(Self.candidateBinaryDirs.joined(separator: ", "))")
        }

        let hasMacFUSE = Self.macFUSEMarkerPaths.contains { FileManager.default.fileExists(atPath: $0) }
        versions["macFUSE"] = hasMacFUSE ? "installed" : "not installed"

        let helperVersion = await HelperClient.shared.ping()
        versions["MountlyHelperTool"] = helperVersion ?? "unreachable"

        return BackendDiagnostics(
            backendName: name,
            installed: await isInstalled(),
            componentVersions: versions,
            notes: notes
        )
    }
}
