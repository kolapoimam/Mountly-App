import Foundation

public enum MountMode: String, Sendable, Codable {
    case readOnly
    case readWrite
}

public struct MountResult: Sendable {
    public let mountPoint: URL
    public let mode: MountMode
    public let writeVerified: Bool

    public init(mountPoint: URL, mode: MountMode, writeVerified: Bool) {
        self.mountPoint = mountPoint
        self.mode = mode
        self.writeVerified = writeVerified
    }
}

public struct BackendStatus: Sendable {
    public let isMounted: Bool
    public let mountPoint: URL?
    public let mode: MountMode?
    public let writeVerified: Bool

    public static let notMounted = BackendStatus(isMounted: false, mountPoint: nil, mode: nil, writeVerified: false)

    public init(isMounted: Bool, mountPoint: URL?, mode: MountMode?, writeVerified: Bool) {
        self.isMounted = isMounted
        self.mountPoint = mountPoint
        self.mode = mode
        self.writeVerified = writeVerified
    }
}

public struct BackendDiagnostics: Sendable {
    public let backendName: String
    public let installed: Bool
    public let componentVersions: [String: String]
    public let notes: [String]

    public init(backendName: String, installed: Bool, componentVersions: [String: String], notes: [String]) {
        self.backendName = backendName
        self.installed = installed
        self.componentVersions = componentVersions
        self.notes = notes
    }
}

/// The seam described in the architecture doc: every part of the app
/// above this line depends only on this protocol, `Drive`, and `TMError` —
/// never on macFUSE or NTFS-3G directly. Adding exFAT/ext4/a future FSKit
/// NTFS module later means writing a new conformer, not touching UI or
/// `MountManager`.
public protocol FilesystemBackend: Sendable {
    var name: String { get }
    var supportedFilesystem: FilesystemKind { get }

    func isInstalled() async -> Bool
    func mount(bsdName: String, mode: MountMode) async throws -> MountResult
    func unmount(mountPoint: URL) async throws
    func verifyRead(mountPoint: URL) async -> Bool
    func verifyWrite(mountPoint: URL) async -> Bool
    func status(mountPoint: URL) async -> BackendStatus
    func diagnostics() async -> BackendDiagnostics
}
