import Foundation

/// Small, real (never fabricated) filesystem stats read directly from the
/// kernel via `statfs`, for display purposes (e.g. "Cluster size").
public enum VolumeInfo {
    /// The filesystem's fundamental allocation unit size in bytes, as
    /// reported by the kernel for the volume mounted at `path`. For
    /// NTFS/exFAT/FAT32 this is the cluster size; for APFS/HFS+ the
    /// allocation block size. Returns `nil` if `path` isn't a mount point
    /// statfs can resolve.
    public static func blockSize(atPath path: String) -> Int? {
        var buf = statfs()
        guard statfs(path, &buf) == 0 else { return nil }
        return Int(buf.f_bsize)
    }
}
