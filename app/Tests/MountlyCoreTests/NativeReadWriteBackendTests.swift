import XCTest
@testable import MountlyCore

final class NativeReadWriteBackendTests: XCTestCase {
    func testMountThrowsDiskNotFoundForNonexistentDevice() async {
        let backend = NativeReadWriteBackend(filesystem: .exfat)
        do {
            _ = try await backend.mount(bsdName: "disk999s1", mode: .readWrite)
            XCTFail("expected mount to throw for a nonexistent device")
        } catch let error as TMError {
            XCTAssertEqual(error, .diskNotFound(bsdName: "disk999s1"))
        } catch {
            XCTFail("unexpected error type: \(error)")
        }
    }

    func testUnmountRefusesPathsOutsideVolumes() async {
        let backend = NativeReadWriteBackend(filesystem: .apfs)
        do {
            try await backend.unmount(mountPoint: URL(fileURLWithPath: "/etc"))
            XCTFail("expected unmount to refuse a path outside /Volumes")
        } catch let error as TMError {
            guard case .unmountFailed = error else {
                XCTFail("expected .unmountFailed, got \(error)")
                return
            }
        } catch {
            XCTFail("unexpected error type: \(error)")
        }
    }

    func testIsInstalledIsAlwaysTrue() async {
        let backend = NativeReadWriteBackend(filesystem: .hfsPlus)
        let installed = await backend.isInstalled()
        XCTAssertTrue(installed)
    }

    func testDiagnosticsReportsBuiltIntoMacOS() async {
        let backend = NativeReadWriteBackend(filesystem: .fat32)
        let diagnostics = await backend.diagnostics()
        XCTAssertTrue(diagnostics.installed)
        XCTAssertEqual(diagnostics.componentVersions[FilesystemKind.fat32.rawValue], "Built into macOS")
    }
}

/// Exercises the shared write-probe logic directly against a real
/// temporary directory — legitimate on any machine, no external hardware
/// needed, and this is exactly the code path every backend relies on
/// before ever claiming "Write access verified".
final class WriteProbeTests: XCTestCase {
    func testVerifyWriteSucceedsOnAWritableDirectoryAndLeavesNoTraceFile() {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("mountly-write-probe-\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }

        XCTAssertTrue(WriteProbe.verifyWrite(mountPoint: dir))
        let remaining = (try? FileManager.default.contentsOfDirectory(atPath: dir.path)) ?? ["unexpected"]
        XCTAssertTrue(remaining.isEmpty, "write probe should leave no trace file behind")
    }

    func testVerifyWriteFailsOnANonexistentDirectory() {
        let bogus = URL(fileURLWithPath: "/nonexistent-\(UUID().uuidString)")
        XCTAssertFalse(WriteProbe.verifyWrite(mountPoint: bogus))
    }

    func testVerifyReadSucceedsOnAnExistingDirectory() {
        XCTAssertTrue(WriteProbe.verifyRead(mountPoint: FileManager.default.temporaryDirectory))
    }
}
