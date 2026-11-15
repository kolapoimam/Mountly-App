import Foundation

/// Thin, read-only wrapper around `diskutil info -plist`. Used only to
/// enrich/cross-check what Disk Arbitration already told us — never to
/// issue any mutating diskutil subcommand. `eraseVolume`, `partitionDisk`,
/// `unmountDisk` (force), `repairVolume`, and every other destructive
/// diskutil verb are intentionally absent from this type and from the rest
/// of the codebase.
public enum DiskUtility {
    public struct Info: Sendable {
        public let bsdName: String
        public let volumeName: String?
        public let filesystemName: String?
        public let removable: Bool
        public let internalDisk: Bool
        public let size: Int64
        public let mountPoint: String?
        public let writable: Bool
    }

    public enum DiskUtilityError: Error {
        case notFound
        case parseFailure
    }

    private static let diskutilPath = "/usr/sbin/diskutil"

    /// Read-only info lookup. Never mutates anything.
    public static func info(forBSDName bsdName: String) throws -> Info {
        let result = try ProcessRunner.run(diskutilPath, arguments: ["info", "-plist", bsdName])
        guard result.succeeded, let data = result.standardOutput.data(using: .utf8), !data.isEmpty else {
            throw DiskUtilityError.notFound
        }
        guard
            let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any]
        else {
            throw DiskUtilityError.parseFailure
        }

        return Info(
            bsdName: plist["DeviceIdentifier"] as? String ?? bsdName,
            volumeName: plist["VolumeName"] as? String,
            filesystemName: plist["FilesystemName"] as? String,
            removable: (plist["RemovableMedia"] as? Bool) ?? (plist["Removable"] as? Bool) ?? false,
            internalDisk: (plist["Internal"] as? Bool) ?? false,
            size: Int64(plist["Size"] as? Int ?? 0),
            mountPoint: plist["MountPoint"] as? String,
            writable: (plist["WritableVolume"] as? Bool) ?? false
        )
    }

    /// Lists external, physical whole disks — used only to populate the
    /// initial drive list at launch; live updates come from Disk
    /// Arbitration callbacks, not polling this.
    public static func externalDiskIdentifiers() throws -> [String] {
        let result = try ProcessRunner.run(diskutilPath, arguments: ["list", "-plist", "external", "physical"])
        guard result.succeeded, let data = result.standardOutput.data(using: .utf8) else {
            return []
        }
        guard
            let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any],
            let disks = plist["AllDisksAndPartitions"] as? [[String: Any]]
        else {
            return []
        }
        var identifiers: [String] = []
        for disk in disks {
            if let partitions = disk["Partitions"] as? [[String: Any]] {
                identifiers.append(contentsOf: partitions.compactMap { $0["DeviceIdentifier"] as? String })
            }
        }
        return identifiers
    }
}
