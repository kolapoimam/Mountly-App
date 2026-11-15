import XCTest
@testable import MountlyCore

@MainActor
final class TransferCalculationsTests: XCTestCase {
    func testFractionCompleteAndTotals() {
        let files = [
            TransferFileItem(sourceURL: URL(fileURLWithPath: "/tmp/a"), destinationURL: URL(fileURLWithPath: "/tmp/b/a"), sizeBytes: 1000),
            TransferFileItem(sourceURL: URL(fileURLWithPath: "/tmp/c"), destinationURL: URL(fileURLWithPath: "/tmp/b/c"), sizeBytes: 3000)
        ]
        let job = TransferJob(direction: .macToDrive, files: files)
        XCTAssertEqual(job.totalBytes, 4000)
        XCTAssertEqual(job.totalFiles, 2)
        XCTAssertEqual(job.fractionComplete, 0, accuracy: 0.0001)

        job.bytesTransferred = 2000
        XCTAssertEqual(job.fractionComplete, 0.5, accuracy: 0.0001)
    }

    func testFractionCompleteWithZeroTotalBytesDoesNotDivideByZero() {
        let job = TransferJob(direction: .driveToMac, files: [])
        XCTAssertEqual(job.fractionComplete, 0)
    }

    func testUniqueDestinationAppendsCopySuffixWithoutCollision() {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }

        let original = dir.appendingPathComponent("photo.jpg")
        FileManager.default.createFile(atPath: original.path, contents: Data())

        let first = TransferManager.uniqueDestination(for: original)
        XCTAssertEqual(first.lastPathComponent, "photo copy.jpg")

        FileManager.default.createFile(atPath: first.path, contents: Data())
        let second = TransferManager.uniqueDestination(for: original)
        XCTAssertEqual(second.lastPathComponent, "photo copy 2.jpg")
    }

    func testUniqueDestinationHandlesFilesWithoutExtension() {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }

        let original = dir.appendingPathComponent("README")
        FileManager.default.createFile(atPath: original.path, contents: Data())

        let unique = TransferManager.uniqueDestination(for: original)
        XCTAssertEqual(unique.lastPathComponent, "README copy")
    }

    func testFormattedRemainingHandlesNilAndZero() {
        XCTAssertEqual(TransferJob.formattedRemaining(nil), "—")
        XCTAssertEqual(TransferJob.formattedRemaining(0), "—")
        XCTAssertTrue(TransferJob.formattedRemaining(125).contains("remaining"))
    }

    func testFormattedSpeedHandlesZero() {
        XCTAssertEqual(TransferJob.formattedSpeed(0), "—")
        XCTAssertTrue(TransferJob.formattedSpeed(1_000_000).contains("/s"))
    }
}
