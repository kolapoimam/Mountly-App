import Foundation

/// Single source of truth for what drives exist and what state they're in.
/// `DriveDetectionService` feeds it from Disk Arbitration; `MountManager`,
/// `EjectManager`, and `TransferManager` mutate it as operations progress;
/// every UI surface (main window, menu bar, Settings) observes it.
@MainActor
public final class DriveStore: ObservableObject, DriveDetectionServiceDelegate {
    public static let shared = DriveStore()

    @Published public private(set) var drives: [Drive] = []

    private let detectionService = DriveDetectionService.shared

    public init() {
        detectionService.delegate = self
    }

    public func start() {
        detectionService.start()
    }

    public func drive(bsdName: String) -> Drive? {
        drives.first { $0.bsdName == bsdName }
    }

    public func updateState(bsdName: String, to state: DriveState) {
        guard let idx = drives.firstIndex(where: { $0.bsdName == bsdName }) else { return }
        drives[idx].state = state
    }

    public func applyMountResult(bsdName: String, mountPoint: URL, writeVerified: Bool) {
        guard let idx = drives.firstIndex(where: { $0.bsdName == bsdName }) else { return }
        drives[idx].mountPoint = mountPoint
        drives[idx].writeVerified = writeVerified
        drives[idx].state = writeVerified ? .mountedReadWrite : .mountedReadOnly
    }

    public func clearMount(bsdName: String) {
        guard let idx = drives.firstIndex(where: { $0.bsdName == bsdName }) else { return }
        drives[idx].mountPoint = nil
        drives[idx].writeVerified = false
        drives[idx].state = .detected
    }

    nonisolated public func driveDetectionService(_ service: DriveDetectionService, didUpdate drive: Drive) {
        Task { @MainActor in
            self.upsert(drive)
        }
    }

    nonisolated public func driveDetectionService(_ service: DriveDetectionService, didRemoveBSDName bsdName: String) {
        Task { @MainActor in
            self.drives.removeAll { $0.bsdName == bsdName }
        }
    }

    private func upsert(_ newDrive: Drive) {
        guard let idx = drives.firstIndex(where: { $0.bsdName == newDrive.bsdName }) else {
            drives.append(newDrive)
            return
        }
        // Disk Arbitration doesn't know about our own write-verified mount
        // state — preserve it if the mount point hasn't changed underneath us.
        var merged = newDrive
        if drives[idx].mountPoint == newDrive.mountPoint {
            merged.writeVerified = drives[idx].writeVerified
            if drives[idx].state == .mountedReadWrite || drives[idx].state.isTransitional {
                merged.state = drives[idx].state
            }
        }
        drives[idx] = merged
    }
}
