import Foundation

/// Backend for filesystems macOS already mounts read/write natively —
/// exFAT, FAT32, APFS, HFS+. No third-party driver, no privileged helper,
/// no system extension: this backend only ever *observes* the mount macOS
/// already made and verifies write access on it, per "use Apple's native
/// filesystem functionality rather than unnecessarily introducing another
/// driver" (docs/ARCHITECTURE.md). Unmounting goes straight through
/// unprivileged `diskutil eject`, since Mountly never privilegedly mounted
/// anything here in the first place.
public struct NativeReadWriteBackend: FilesystemBackend {
    public let name = "macOS Native"
    public let supportedFilesystem: FilesystemKind

    public init(filesystem: FilesystemKind) {
        precondition(filesystem.isNativelySupported, "NativeReadWriteBackend only supports natively-mountable filesystems")
        self.supportedFilesystem = filesystem
    }

    public func isInstalled() async -> Bool { true }

    public func mount(bsdName: String, mode: MountMode) async throws -> MountResult {
        guard let info = try? DiskUtility.info(forBSDName: bsdName) else {
            throw TMError.diskNotFound(bsdName: bsdName)
        }
        guard !info.internalDisk else { throw TMError.internalDiskRefused }

        let filesystem = FilesystemKind(diskArbitrationFilesystemName: info.filesystemName ?? "")
        guard filesystem == supportedFilesystem else { throw TMError.unexpectedFilesystem(actual: filesystem) }

        // macOS already auto-mounts these; if it hasn't for some reason
        // (e.g. the volume was previously ejected from Finder), ask
        // diskutil to mount it — this is a normal, unprivileged operation
        // for the user's own external volume, not a privileged one.
        var mountPointPath = info.mountPoint
        if mountPointPath == nil || mountPointPath?.isEmpty == true {
            _ = try? ProcessRunner.run("/usr/sbin/diskutil", arguments: ["mount", "/dev/\(bsdName)"])
            mountPointPath = try? DiskUtility.info(forBSDName: bsdName).mountPoint
        }
        guard let resolvedPath = mountPointPath, !resolvedPath.isEmpty else {
            throw TMError.mountFailed(technicalDetail: "no native mount point available for \(bsdName)")
        }

        let mountPoint = URL(fileURLWithPath: resolvedPath)
        guard await verifyRead(mountPoint: mountPoint) else {
            throw TMError.mountFailed(technicalDetail: "read check failed for \(resolvedPath)")
        }

        var writeVerified = false
        if mode == .readWrite {
            writeVerified = await verifyWrite(mountPoint: mountPoint)
        }

        return MountResult(mountPoint: mountPoint, mode: writeVerified ? .readWrite : .readOnly, writeVerified: writeVerified)
    }

    public func unmount(mountPoint: URL) async throws {
        guard mountPoint.path.hasPrefix("/Volumes/") else {
            throw TMError.unmountFailed(technicalDetail: "refusing to unmount a path outside /Volumes")
        }
        let result = try ProcessRunner.run("/usr/sbin/diskutil", arguments: ["eject", mountPoint.path])
        guard result.succeeded else {
            throw TMError.unmountFailed(technicalDetail: result.standardError.isEmpty ? result.standardOutput : result.standardError)
        }
    }

    public func verifyRead(mountPoint: URL) async -> Bool {
        WriteProbe.verifyRead(mountPoint: mountPoint)
    }

    public func verifyWrite(mountPoint: URL) async -> Bool {
        WriteProbe.verifyWrite(mountPoint: mountPoint)
    }

    public func status(mountPoint: URL) async -> BackendStatus {
        guard WriteProbe.verifyRead(mountPoint: mountPoint) else { return .notMounted }
        let writable = await verifyWrite(mountPoint: mountPoint)
        return BackendStatus(isMounted: true, mountPoint: mountPoint, mode: writable ? .readWrite : .readOnly, writeVerified: writable)
    }

    public func diagnostics() async -> BackendDiagnostics {
        BackendDiagnostics(
            backendName: name,
            installed: true,
            componentVersions: [supportedFilesystem.rawValue: "Built into macOS"],
            notes: []
        )
    }
}
