import Foundation

/// How the drive is physically connected, where detectable via IOKit.
public enum ConnectionType: String, Sendable, Codable {
    case usb = "USB"
    case thunderbolt = "Thunderbolt"
    case sata = "SATA"
    case unknown = "Unknown"
}

/// A snapshot of one physical/external volume Mountly knows about.
/// Immutable value type — `DriveStore` (an `ObservableObject`) is the thing
/// that holds and republishes the current array of these as state changes.
public struct Drive: Identifiable, Equatable, Sendable {
    /// The BSD device identifier, e.g. "disk4s1". Stable for the life of a
    /// single connection; changes if the drive is unplugged and replugged.
    public let bsdName: String
    public var id: String { bsdName }

    public var volumeName: String
    public var filesystem: FilesystemKind
    public var capacityBytes: Int64
    public var usedBytes: Int64
    public var freeBytes: Int64
    public var isRemovable: Bool
    public var isInternal: Bool
    public var connectionType: ConnectionType
    public var mountPoint: URL?
    public var state: DriveState
    public var writeVerified: Bool
    public var lastDetected: Date

    public init(
        bsdName: String,
        volumeName: String,
        filesystem: FilesystemKind,
        capacityBytes: Int64,
        usedBytes: Int64,
        freeBytes: Int64,
        isRemovable: Bool,
        isInternal: Bool,
        connectionType: ConnectionType,
        mountPoint: URL?,
        state: DriveState,
        writeVerified: Bool = false,
        lastDetected: Date = Date()
    ) {
        self.bsdName = bsdName
        self.volumeName = volumeName
        self.filesystem = filesystem
        self.capacityBytes = capacityBytes
        self.usedBytes = usedBytes
        self.freeBytes = freeBytes
        self.isRemovable = isRemovable
        self.isInternal = isInternal
        self.connectionType = connectionType
        self.mountPoint = mountPoint
        self.state = state
        self.writeVerified = writeVerified
        self.lastDetected = lastDetected
    }

    /// A drive is only ever eligible for mounting/writing operations if it
    /// passes this. Internal disks and the boot volume are refused even if
    /// somehow reported as a supported filesystem (they never legitimately
    /// would be).
    ///
    /// Deliberately keyed off `isInternal` alone, not `isRemovable`: Disk
    /// Arbitration's "removable media" flag means media that's removable
    /// *from* a fixed drive mechanism (an optical tray, an SD card slot) —
    /// most external SSDs and HDDs report `Removable = false` while being
    /// perfectly safe, ejectable, external devices. Gating on `isRemovable`
    /// incorrectly refused real external drives; `isInternal` (backed by
    /// IOKit's own internal/external bus classification) is the signal
    /// that actually distinguishes "this is the Mac's own storage."
    public var isEligibleForManagement: Bool {
        !isInternal && !isBootVolume
    }

    /// True only for the actual startup disk's volume — refused even if,
    /// somehow, `isInternal` were misreported.
    public var isBootVolume: Bool {
        mountPoint?.path == "/"
    }

    public static func == (lhs: Drive, rhs: Drive) -> Bool {
        lhs.bsdName == rhs.bsdName &&
        lhs.volumeName == rhs.volumeName &&
        lhs.filesystem == rhs.filesystem &&
        lhs.capacityBytes == rhs.capacityBytes &&
        lhs.usedBytes == rhs.usedBytes &&
        lhs.freeBytes == rhs.freeBytes &&
        lhs.mountPoint == rhs.mountPoint &&
        lhs.state == rhs.state &&
        lhs.writeVerified == rhs.writeVerified
    }
}

extension Drive {
    public static func byteCountString(_ bytes: Int64) -> String {
        ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
    }

    public var capacityString: String { Self.byteCountString(capacityBytes) }
    public var usedString: String { Self.byteCountString(usedBytes) }
    public var freeString: String { Self.byteCountString(freeBytes) }
}
