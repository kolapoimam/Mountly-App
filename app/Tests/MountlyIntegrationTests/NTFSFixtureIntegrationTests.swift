import XCTest
@testable import MountlyCore

/// Integration coverage against a disposable, on-the-fly loopback NTFS
/// image — never a real physical disk. Requires the
/// dev-only `mkntfs`/`ntfs-3g` tools (e.g. `brew install ntfs-3g`); skips
/// itself cleanly when they aren't present rather than failing the suite,
/// since end users and CI machines are not expected to have them.
final class NTFSFixtureIntegrationTests: XCTestCase {
    private static func findBinary(_ name: String) -> String? {
        for dir in ["/opt/homebrew/bin", "/opt/homebrew/sbin", "/usr/local/bin", "/usr/local/sbin"] {
            let path = dir + "/" + name
            if FileManager.default.isExecutableFile(atPath: path) { return path }
        }
        return nil
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        guard Self.findBinary("mkntfs") != nil, Self.findBinary("ntfs-3g") != nil else {
            throw XCTSkip("mkntfs/ntfs-3g not installed — this is dev-only tooling used solely to build a disposable test image (run `brew install ntfs-3g` to enable this test). The app itself never requires this on an end user's Mac.")
        }
    }

    func testCreateWriteReadUnicodeAndNestedFilesOnLoopbackNTFSImage() throws {
        let tmpDir = FileManager.default.temporaryDirectory.appendingPathComponent("tm-ntfs-test-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tmpDir) }

        // 1. A disposable 64MB raw image file — never a real disk.
        let imageURL = tmpDir.appendingPathComponent("ntfs-test.img")
        FileManager.default.createFile(atPath: imageURL.path, contents: nil)
        let handle = try FileHandle(forWritingTo: imageURL)
        try handle.truncate(atOffset: 64 * 1024 * 1024)
        try handle.close()

        // 2. Attach as an unformatted raw loopback device.
        let attach = try ProcessRunner.run(
            "/usr/bin/hdiutil",
            arguments: ["attach", "-imagekey", "diskimage-class=CRawDiskImage", "-nomount", imageURL.path, "-plist"]
        )
        guard attach.succeeded,
              let attachData = attach.standardOutput.data(using: .utf8),
              let attachPlist = try? PropertyListSerialization.propertyList(from: attachData, options: [], format: nil) as? [String: Any],
              let entities = attachPlist["system-entities"] as? [[String: Any]],
              let devicePath = entities.compactMap({ $0["dev-entry"] as? String }).first
        else {
            XCTFail("hdiutil attach failed: \(attach.standardError)")
            return
        }
        defer { _ = try? ProcessRunner.run("/usr/bin/hdiutil", arguments: ["detach", devicePath, "-force"]) }

        // 3. Format as NTFS with mkntfs — dev-only tooling, applied only to
        //    this disposable loopback device, never a physical disk.
        let format = try ProcessRunner.run(Self.findBinary("mkntfs")!, arguments: ["-Q", "-F", "-L", "TMTest", devicePath])
        XCTAssertTrue(format.succeeded, "mkntfs failed: \(format.standardError)")

        // 4. Mount directly via ntfs-3g (this exercises NTFS-3G's own
        //    behavior; the XPC helper path is covered separately by manual
        //    verification per docs/RELEASE.md, since it requires a signed
        //    app bundle and admin-authorized daemon registration).
        let mountPointURL = tmpDir.appendingPathComponent("mnt")
        try FileManager.default.createDirectory(at: mountPointURL, withIntermediateDirectories: true)
        let mount = try ProcessRunner.run(Self.findBinary("ntfs-3g")!, arguments: [devicePath, mountPointURL.path, "-o", "local,allow_other"])
        XCTAssertTrue(mount.succeeded, "ntfs-3g mount failed: \(mount.standardError)")
        defer { _ = try? ProcessRunner.run("/usr/sbin/diskutil", arguments: ["unmount", mountPointURL.path]) }

        // 5. Filenames: spaces, apostrophes, parentheses, Unicode (Arabic,
        //    Yoruba) inside a nested folder tree.
        let names = [
            "simple.txt",
            "with spaces.txt",
            "O'Brien's Notes.txt",
            "(parens) & [brackets].txt",
            "مرحبا-بالعالم.txt",
            "Ẹ ku ọjọ́ Yorùbá.txt"
        ]
        let nested = mountPointURL.appendingPathComponent("nested/deeper/folder")
        try FileManager.default.createDirectory(at: nested, withIntermediateDirectories: true)

        for name in names {
            let content = "content-for-\(name)".data(using: .utf8)!
            let fileURL = nested.appendingPathComponent(name)
            try content.write(to: fileURL)
            let readBack = try Data(contentsOf: fileURL)
            XCTAssertEqual(readBack, content, "round-trip failed for filename: \(name)")
        }

        let listing = try FileManager.default.contentsOfDirectory(atPath: nested.path)
        XCTAssertEqual(Set(listing).count, names.count, "expected all \(names.count) distinct filenames to survive on NTFS")
    }

    func testLargerFileChecksumRoundTrip() throws {
        let tmpDir = FileManager.default.temporaryDirectory.appendingPathComponent("tm-ntfs-test-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tmpDir) }

        let imageURL = tmpDir.appendingPathComponent("ntfs-test.img")
        FileManager.default.createFile(atPath: imageURL.path, contents: nil)
        let handle = try FileHandle(forWritingTo: imageURL)
        try handle.truncate(atOffset: 96 * 1024 * 1024)
        try handle.close()

        let attach = try ProcessRunner.run(
            "/usr/bin/hdiutil",
            arguments: ["attach", "-imagekey", "diskimage-class=CRawDiskImage", "-nomount", imageURL.path, "-plist"]
        )
        guard attach.succeeded,
              let attachData = attach.standardOutput.data(using: .utf8),
              let attachPlist = try? PropertyListSerialization.propertyList(from: attachData, options: [], format: nil) as? [String: Any],
              let entities = attachPlist["system-entities"] as? [[String: Any]],
              let devicePath = entities.compactMap({ $0["dev-entry"] as? String }).first
        else {
            XCTFail("hdiutil attach failed")
            return
        }
        defer { _ = try? ProcessRunner.run("/usr/bin/hdiutil", arguments: ["detach", devicePath, "-force"]) }

        let format = try ProcessRunner.run(Self.findBinary("mkntfs")!, arguments: ["-Q", "-F", "-L", "TMTest2", devicePath])
        XCTAssertTrue(format.succeeded)

        let mountPointURL = tmpDir.appendingPathComponent("mnt")
        try FileManager.default.createDirectory(at: mountPointURL, withIntermediateDirectories: true)
        let mount = try ProcessRunner.run(Self.findBinary("ntfs-3g")!, arguments: [devicePath, mountPointURL.path, "-o", "local,allow_other"])
        XCTAssertTrue(mount.succeeded)
        defer { _ = try? ProcessRunner.run("/usr/sbin/diskutil", arguments: ["unmount", mountPointURL.path]) }

        // ~20MB of pseudo-random data — large enough to exercise multi-chunk I/O.
        var generator = SystemRandomNumberGenerator()
        var bytes = [UInt8](repeating: 0, count: 20 * 1024 * 1024)
        for i in bytes.indices { bytes[i] = UInt8.random(in: 0...255, using: &generator) }
        let original = Data(bytes)

        let fileURL = mountPointURL.appendingPathComponent("large-file.bin")
        try original.write(to: fileURL)

        let readBack = try Data(contentsOf: fileURL)
        XCTAssertEqual(readBack.count, original.count)
        XCTAssertEqual(readBack, original, "checksum/content mismatch after NTFS round-trip")
    }
}
