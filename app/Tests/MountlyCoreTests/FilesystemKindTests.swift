import XCTest
@testable import MountlyCore

final class FilesystemKindTests: XCTestCase {
    func testRecognizesNTFSFromDiskArbitrationStrings() {
        XCTAssertEqual(FilesystemKind(diskArbitrationFilesystemName: "ntfs"), .ntfs)
        XCTAssertEqual(FilesystemKind(diskArbitrationFilesystemName: "NTFS"), .ntfs)
    }

    func testRecognizesOtherCommonFilesystems() {
        XCTAssertEqual(FilesystemKind(diskArbitrationFilesystemName: "exfat"), .exfat)
        XCTAssertEqual(FilesystemKind(diskArbitrationFilesystemName: "apfs"), .apfs)
        XCTAssertEqual(FilesystemKind(diskArbitrationFilesystemName: "hfs"), .hfsPlus)
        XCTAssertEqual(FilesystemKind(diskArbitrationFilesystemName: "msdos"), .fat32)
    }

    func testUnknownStringMapsToUnknownNeverToNTFS() {
        XCTAssertEqual(FilesystemKind(diskArbitrationFilesystemName: "zfs"), .unknown)
        XCTAssertEqual(FilesystemKind(diskArbitrationFilesystemName: ""), .unknown)
        XCTAssertNotEqual(FilesystemKind(diskArbitrationFilesystemName: "zfs"), .ntfs)
    }

    func testRecognizesExt4AndLinuxVariants() {
        XCTAssertEqual(FilesystemKind(diskArbitrationFilesystemName: "ext4"), .ext4)
        XCTAssertEqual(FilesystemKind(diskArbitrationFilesystemName: "ext3"), .ext4)
        XCTAssertEqual(FilesystemKind(diskArbitrationFilesystemName: "linux"), .ext4)
    }

    /// NTFS (third-party driver) and exFAT/FAT32/APFS/HFS+ (native macOS
    /// support) all have a real backend; ext4 and unknown filesystems do
    /// not, and must never claim otherwise.
    func testReadWriteBackendClaimIsAccurate() {
        let supported: Set<FilesystemKind> = [.ntfs, .exfat, .fat32, .apfs, .hfsPlus]
        for kind in FilesystemKind.allCases {
            if supported.contains(kind) {
                XCTAssertTrue(kind.hasReadWriteBackend, "\(kind) should claim read/write support")
            } else {
                XCTAssertFalse(kind.hasReadWriteBackend, "\(kind) should not claim read/write support")
            }
        }
    }

    func testNativelySupportedExcludesNTFSAndExt4() {
        XCTAssertTrue(FilesystemKind.exfat.isNativelySupported)
        XCTAssertTrue(FilesystemKind.fat32.isNativelySupported)
        XCTAssertTrue(FilesystemKind.apfs.isNativelySupported)
        XCTAssertTrue(FilesystemKind.hfsPlus.isNativelySupported)
        XCTAssertFalse(FilesystemKind.ntfs.isNativelySupported)
        XCTAssertFalse(FilesystemKind.ext4.isNativelySupported)
        XCTAssertFalse(FilesystemKind.unknown.isNativelySupported)
    }
}
