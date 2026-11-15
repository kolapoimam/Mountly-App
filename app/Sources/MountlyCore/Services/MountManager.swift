import Foundation

/// Orchestrates safe mounting. Never claims write access without the
/// backend actually verifying it; maps known NTFS-3G failure messages to
/// the specific "unsafe Windows state" / "dirty filesystem" states instead
/// of a generic error, so the UI can show the right explanation.
@MainActor
public final class MountManager: ObservableObject {
    public static let shared = MountManager(registry: .default)

    private let registry: BackendRegistry

    public init(registry: BackendRegistry) {
        self.registry = registry
    }

    public func enableReadWrite(for bsdName: String, store: DriveStore) async {
        guard let drive = store.drive(bsdName: bsdName) else { return }
        guard !drive.isInternal else {
            store.updateState(bsdName: bsdName, to: .error(.internalDiskRefused))
            return
        }
        guard !drive.isBootVolume else {
            store.updateState(bsdName: bsdName, to: .error(.bootVolumeRefused))
            return
        }
        guard let backend = registry.backend(for: drive.filesystem) else {
            store.updateState(bsdName: bsdName, to: .unsupportedFilesystem(drive.filesystem))
            return
        }

        await EventLog.shared.record("Enabling read/write for \(bsdName)", category: .mountManager)

        guard await backend.isInstalled() else {
            store.updateState(bsdName: bsdName, to: .error(.backendNotInstalled))
            return
        }

        store.updateState(bsdName: bsdName, to: .preparing)
        store.updateState(bsdName: bsdName, to: .mounting)

        do {
            let result = try await backend.mount(bsdName: bsdName, mode: .readWrite)
            store.applyMountResult(bsdName: bsdName, mountPoint: result.mountPoint, writeVerified: result.writeVerified)
            await EventLog.shared.record("Mounted \(bsdName) read/write, verified=\(result.writeVerified)", category: .mountManager)
        } catch let error as TMError {
            let mapped = Self.mapKnownFailure(error)
            store.updateState(bsdName: bsdName, to: mapped)
            await EventLog.shared.record("Mount failed for \(bsdName): \(error)", category: .mountManager)
        } catch {
            store.updateState(bsdName: bsdName, to: .error(.mountFailed(technicalDetail: String(describing: error))))
        }
    }

    public func mountReadOnly(for bsdName: String, store: DriveStore) async {
        guard let drive = store.drive(bsdName: bsdName) else { return }
        guard let backend = registry.backend(for: drive.filesystem) else {
            store.updateState(bsdName: bsdName, to: .unsupportedFilesystem(drive.filesystem))
            return
        }
        store.updateState(bsdName: bsdName, to: .mounting)
        do {
            let result = try await backend.mount(bsdName: bsdName, mode: .readOnly)
            store.applyMountResult(bsdName: bsdName, mountPoint: result.mountPoint, writeVerified: false)
            store.updateState(bsdName: bsdName, to: .mountedReadOnly)
        } catch let error as TMError {
            store.updateState(bsdName: bsdName, to: .error(error))
        } catch {
            store.updateState(bsdName: bsdName, to: .error(.mountFailed(technicalDetail: String(describing: error))))
        }
    }

    /// Silent, no-user-action write verification for filesystems macOS
    /// already mounts read/write natively (exFAT/FAT32/APFS/HFS+). Never
    /// surfaces an error if the probe fails (e.g. a locked/read-only card)
    /// — it just leaves the drive at "Read Only" and lets the user opt
    /// into a retry from the UI like any other drive.
    public func autoVerifyIfNativelyWritable(bsdName: String, store: DriveStore) async {
        guard let drive = store.drive(bsdName: bsdName),
              drive.state == .mountedReadOnly,
              let mountPoint = drive.mountPoint,
              let backend = registry.backend(for: drive.filesystem) else { return }

        if await backend.verifyWrite(mountPoint: mountPoint) {
            store.applyMountResult(bsdName: bsdName, mountPoint: mountPoint, writeVerified: true)
            await EventLog.shared.record("Auto-verified native read/write for \(bsdName)", category: .mountManager)
        }
    }

    /// Translates raw NTFS-3G failure text into the specific safety states
    /// described in docs/SECURITY.md — never invented, matched against the well-known
    /// phrases NTFS-3G itself emits when it refuses an unsafe mount.
    nonisolated static func mapKnownFailure(_ error: TMError) -> DriveState {
        guard case .mountFailed(let detail) = error else { return .error(error) }
        let lowered = detail.lowercased()
        if lowered.contains("hibernat") {
            return .windowsHibernationDetected
        }
        if lowered.contains("dirty") || lowered.contains("scheduled for a check") || lowered.contains("chkdsk") || lowered.contains("$logfile") {
            return .dirtyFilesystem
        }
        return .error(error)
    }
}
