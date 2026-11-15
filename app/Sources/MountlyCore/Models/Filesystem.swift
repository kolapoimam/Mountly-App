import Foundation

/// Filesystem kinds Mountly can recognize, independent of any drive
/// manufacturer — detection is entirely by filesystem type. `hasReadWriteBackend`
/// must stay in sync with whatever's actually registered in
/// `BackendRegistry.default`; nothing here implies support on its own.
public enum FilesystemKind: String, Sendable, CaseIterable, Codable {
    case ntfs = "NTFS"
    case exfat = "exFAT"
    case fat32 = "FAT32"
    case apfs = "APFS"
    case hfsPlus = "HFS+"
    case ext4 = "EXT4"
    case unknown = "Unknown"

    /// Whether Mountly currently ships a backend capable of mounting this
    /// filesystem read/write — either natively (macOS already supports
    /// exFAT/FAT32/APFS/HFS+ read/write out of the box) or via a bundled
    /// third-party driver (NTFS, via macFUSE + NTFS-3G). `ext4` and
    /// `unknown` deliberately have none: there is no safe, modular,
    /// actively-maintained macOS ext4 read/write driver to wrap, and
    /// Mountly does not implement filesystem drivers from scratch merely
    /// to claim support (see docs/ARCHITECTURE.md).
    public var hasReadWriteBackend: Bool {
        self != .ext4 && self != .unknown
    }

    /// True for filesystems macOS already mounts read/write natively,
    /// with no third-party component required at all.
    public var isNativelySupported: Bool {
        switch self {
        case .exfat, .fat32, .apfs, .hfsPlus: return true
        case .ntfs, .ext4, .unknown: return false
        }
    }

    public init(diskArbitrationFilesystemName raw: String) {
        let normalized = raw.lowercased()
        switch normalized {
        case let s where s.contains("ntfs"):
            self = .ntfs
        case let s where s.contains("exfat"):
            self = .exfat
        case let s where s.contains("msdos"), let s where s.contains("fat32"), let s where s.contains("fat"):
            self = .fat32
        case let s where s.contains("apfs"):
            self = .apfs
        case let s where s.contains("hfs"):
            self = .hfsPlus
        case let s where s.contains("ext4"), let s where s.contains("ext3"), let s where s.contains("ext2"), let s where s.contains("linux"):
            self = .ext4
        default:
            self = .unknown
        }
    }
}
