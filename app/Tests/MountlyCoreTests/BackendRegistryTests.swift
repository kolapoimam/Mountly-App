import XCTest
@testable import MountlyCore

final class BackendRegistryTests: XCTestCase {
    func testDefaultRegistryHasNTFSBackend() {
        let backend = BackendRegistry.default.backend(for: .ntfs)
        XCTAssertNotNil(backend)
        XCTAssertEqual(backend?.supportedFilesystem, .ntfs)
    }

    func testDefaultRegistryHasNativeBackendsForOSSupportedFilesystems() {
        for kind: FilesystemKind in [.exfat, .fat32, .apfs, .hfsPlus] {
            let backend = BackendRegistry.default.backend(for: kind)
            XCTAssertNotNil(backend, "\(kind) should have a native backend")
            XCTAssertEqual(backend?.supportedFilesystem, kind)
        }
    }

    func testDefaultRegistryHasNoBackendForUnsupportedFilesystems() {
        XCTAssertNil(BackendRegistry.default.backend(for: .ext4))
        XCTAssertNil(BackendRegistry.default.backend(for: .unknown))
    }

    func testCustomRegistryIsIsolatedFromDefault() {
        struct StubBackend: FilesystemBackend {
            let name = "stub"
            let supportedFilesystem: FilesystemKind = .exfat
            func isInstalled() async -> Bool { true }
            func mount(bsdName: String, mode: MountMode) async throws -> MountResult {
                MountResult(mountPoint: URL(fileURLWithPath: "/Volumes/stub"), mode: mode, writeVerified: true)
            }
            func unmount(mountPoint: URL) async throws {}
            func verifyRead(mountPoint: URL) async -> Bool { true }
            func verifyWrite(mountPoint: URL) async -> Bool { true }
            func status(mountPoint: URL) async -> BackendStatus { .notMounted }
            func diagnostics() async -> BackendDiagnostics {
                BackendDiagnostics(backendName: name, installed: true, componentVersions: [:], notes: [])
            }
        }

        let registry = BackendRegistry(backends: [.exfat: StubBackend()])
        XCTAssertNotNil(registry.backend(for: .exfat))
        XCTAssertNil(registry.backend(for: .ntfs))
    }
}
