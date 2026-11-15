import Foundation

/// The entire privileged surface of Mountly. `MountlyHelperTool` implements this; the app talks
/// to it over `NSXPCConnection`. There is deliberately no "run this command
/// string" method anywhere on this protocol.
@objc public protocol HelperXPCProtocol {
    /// Mounts `bsdName` (e.g. "disk4s1") at `mountPoint` using NTFS-3G.
    /// The helper independently re-validates via Disk Arbitration that
    /// `bsdName` is external, non-internal, non-boot, and NTFS before doing
    /// anything — it does not trust the caller's word for it.
    func mountNTFS(
        bsdName: String,
        mountPoint: String,
        readOnly: Bool,
        withReply reply: @escaping (Bool, String?) -> Void
    )

    /// Unmounts whatever is mounted at `mountPoint`. Refuses any path
    /// outside `/Volumes`.
    func unmount(
        mountPoint: String,
        withReply reply: @escaping (Bool, String?) -> Void
    )

    /// Read-only status check of an existing mount point.
    func status(
        mountPoint: String,
        withReply reply: @escaping (Bool, String?) -> Void
    )

    /// Liveness/version check, used by Diagnostics and by the app at
    /// launch to detect a stale/crashed helper.
    func ping(withReply reply: @escaping (String) -> Void)
}

public enum HelperXPC {
    public static let machServiceName = "com.mountly.app.helper"
}
