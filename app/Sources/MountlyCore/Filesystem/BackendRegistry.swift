import Foundation

/// Maps a `FilesystemKind` to the `FilesystemBackend` that handles it.
/// `MountManager` and the UI depend on this, never on a specific backend
/// type directly — adding a new filesystem means registering a backend
/// here, nothing else changes. `ext4` and `unknown` are deliberately
/// unregistered: there is no safe backend for them, so the UI shows
/// "Detected — Limited Support" rather than pretending otherwise.
public struct BackendRegistry: Sendable {
    private let backends: [FilesystemKind: FilesystemBackend]

    public static let `default` = BackendRegistry(backends: [
        .ntfs: NTFSBackend(),
        .exfat: NativeReadWriteBackend(filesystem: .exfat),
        .fat32: NativeReadWriteBackend(filesystem: .fat32),
        .apfs: NativeReadWriteBackend(filesystem: .apfs),
        .hfsPlus: NativeReadWriteBackend(filesystem: .hfsPlus)
    ])

    public init(backends: [FilesystemKind: FilesystemBackend]) {
        self.backends = backends
    }

    public func backend(for kind: FilesystemKind) -> FilesystemBackend? {
        backends[kind]
    }
}
