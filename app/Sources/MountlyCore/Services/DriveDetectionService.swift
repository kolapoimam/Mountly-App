import Foundation
import DiskArbitration

public protocol DriveDetectionServiceDelegate: AnyObject {
    func driveDetectionService(_ service: DriveDetectionService, didUpdate drive: Drive)
    func driveDetectionService(_ service: DriveDetectionService, didRemoveBSDName bsdName: String)
}

/// Native drive detection via Disk Arbitration — no polling. DA
/// delivers appear/disappear/description-changed callbacks the instant the
/// kernel reports a change, which is how insertion is detected quickly and
/// removal updates the UI immediately, per the brief.
public final class DriveDetectionService: @unchecked Sendable {
    public static let shared = DriveDetectionService()

    private var session: DASession?
    private let queue = DispatchQueue(label: "com.mountly.app.diskarbitration")
    public weak var delegate: DriveDetectionServiceDelegate?

    private init() {}

    public func start() {
        guard session == nil else { return }
        guard let session = DASessionCreate(kCFAllocatorDefault) else {
            TMLog.error("Failed to create DASession", category: .driveDetection)
            return
        }
        self.session = session
        DASessionSetDispatchQueue(session, queue)

        let context = Unmanaged.passUnretained(self).toOpaque()

        DARegisterDiskAppearedCallback(session, nil, { disk, context in
            guard let context else { return }
            Unmanaged<DriveDetectionService>.fromOpaque(context).takeUnretainedValue().handleDiskAppeared(disk)
        }, context)

        DARegisterDiskDisappearedCallback(session, nil, { disk, context in
            guard let context else { return }
            Unmanaged<DriveDetectionService>.fromOpaque(context).takeUnretainedValue().handleDiskDisappeared(disk)
        }, context)

        DARegisterDiskDescriptionChangedCallback(session, nil, nil, { disk, _, context in
            guard let context else { return }
            Unmanaged<DriveDetectionService>.fromOpaque(context).takeUnretainedValue().handleDiskAppeared(disk)
        }, context)

        TMLog.info("Disk Arbitration session started", category: .driveDetection)
    }

    public func stop() {
        guard let session else { return }
        DASessionSetDispatchQueue(session, nil)
        self.session = nil
    }

    private func handleDiskAppeared(_ disk: DADisk) {
        guard let drive = Self.makeDrive(from: disk) else { return }
        TMLog.info("Disk description available: \(drive.bsdName) (\(drive.filesystem.rawValue))", category: .driveDetection)
        delegate?.driveDetectionService(self, didUpdate: drive)
    }

    private func handleDiskDisappeared(_ disk: DADisk) {
        guard let bsdNamePtr = DADiskGetBSDName(disk) else { return }
        let bsdName = String(cString: bsdNamePtr)
        TMLog.info("Disk disappeared: \(bsdName)", category: .driveDetection)
        delegate?.driveDetectionService(self, didRemoveBSDName: bsdName)
    }

    /// Partition-content GUIDs that are never a data volume worth showing a
    /// card for (EFI System, the APFS container itself — its child volumes
    /// get their own callbacks with a real volume kind, Apple_Boot,
    /// Microsoft Reserved). Everything else without a recognized volume
    /// kind is treated as "detected, limited support" (typically ext4 or
    /// another filesystem macOS has no volume plugin for at all).
    private static let nonDataPartitionContentHints: Set<String> = [
        "C12A7328-F81F-11D2-BA4B-00A0C93EC93B", // EFI System
        "7C3457EF-0000-11AA-AA11-00306543ECAC", // Apple_APFS container
        "426F6F74-0000-11AA-AA11-00306543ECAC", // Apple_Boot
        "E3C9E316-0B5C-4DB8-817D-F92DF00215AE"  // Microsoft Reserved
    ]

    static func makeDrive(from disk: DADisk) -> Drive? {
        guard let descRef = DADiskCopyDescription(disk) else { return nil }
        let desc = descRef as NSDictionary
        guard let bsdNamePtr = DADiskGetBSDName(disk) else { return nil }
        let bsdName = String(cString: bsdNamePtr)

        // Whole disks (e.g. "disk4") aren't individually mountable —
        // only their partitions/volumes are.
        let isWholeDisk = (desc[kDADiskDescriptionMediaWholeKey as String] as? Bool) ?? false
        guard !isWholeDisk else { return nil }

        let isInternal = (desc[kDADiskDescriptionDeviceInternalKey as String] as? Bool) ?? false
        let removable = (desc[kDADiskDescriptionMediaRemovableKey as String] as? Bool) ?? false
        let ejectable = (desc[kDADiskDescriptionMediaEjectableKey as String] as? Bool) ?? false
        let volumeName = (desc[kDADiskDescriptionVolumeNameKey as String] as? String) ?? bsdName
        let size = (desc[kDADiskDescriptionMediaSizeKey as String] as? NSNumber)?.int64Value ?? 0
        let mountPathURL = desc[kDADiskDescriptionVolumePathKey as String] as? URL
        let protocolName = (desc[kDADiskDescriptionDeviceProtocolKey as String] as? String) ?? "Unknown"

        let volumeKind = desc[kDADiskDescriptionVolumeKindKey as String] as? String
        let contentHint = desc[kDADiskDescriptionMediaContentKey as String] as? String

        let filesystem: FilesystemKind
        if let volumeKind {
            filesystem = FilesystemKind(diskArbitrationFilesystemName: volumeKind)
        } else if !isInternal, let contentHint, !Self.nonDataPartitionContentHints.contains(contentHint.uppercased()) {
            // A partition macOS can identify at the partition-table level
            // but has no volume driver for at all — e.g. ext4. Only
            // surfaced for external disks, to avoid noise from internal
            // system partitions.
            filesystem = .unknown
        } else {
            return nil
        }

        let connectionType: ConnectionType
        switch protocolName.lowercased() {
        case let p where p.contains("usb"): connectionType = .usb
        case let p where p.contains("thunderbolt"): connectionType = .thunderbolt
        case let p where p.contains("ata"): connectionType = .sata
        default: connectionType = .unknown
        }

        var usedBytes: Int64 = 0
        var freeBytes: Int64 = size
        if let mountPathURL,
           let values = try? mountPathURL.resourceValues(forKeys: [.volumeAvailableCapacityKey, .volumeTotalCapacityKey]),
           let total = values.volumeTotalCapacity {
            freeBytes = Int64(values.volumeAvailableCapacity ?? 0)
            usedBytes = max(Int64(total) - freeBytes, 0)
        }

        let state: DriveState
        if !filesystem.hasReadWriteBackend {
            // No backend exists (or ever will, safely) for this filesystem
            // — never imply otherwise.
            state = .unsupportedFilesystem(filesystem)
        } else if mountPathURL != nil {
            state = .mountedReadOnly
        } else {
            state = .detected
        }

        return Drive(
            bsdName: bsdName,
            volumeName: volumeName,
            filesystem: filesystem,
            capacityBytes: size,
            usedBytes: usedBytes,
            freeBytes: max(freeBytes, 0),
            isRemovable: removable || ejectable,
            isInternal: isInternal,
            connectionType: connectionType,
            mountPoint: mountPathURL,
            state: state
        )
    }
}
