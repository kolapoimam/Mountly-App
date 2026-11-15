import XCTest
@testable import MountlyCore

final class DriveStateTests: XCTestCase {
    func testIsMountedTrueOnlyForMountedStates() {
        XCTAssertTrue(DriveState.mountedReadWrite.isMounted)
        XCTAssertTrue(DriveState.mountedReadOnly.isMounted)
        XCTAssertFalse(DriveState.detected.isMounted)
        XCTAssertFalse(DriveState.notConnected.isMounted)
        XCTAssertFalse(DriveState.dirtyFilesystem.isMounted)
    }

    func testIsTransitionalCoversAllInFlightStates() {
        XCTAssertTrue(DriveState.detecting.isTransitional)
        XCTAssertTrue(DriveState.preparing.isTransitional)
        XCTAssertTrue(DriveState.mounting.isTransitional)
        XCTAssertTrue(DriveState.unmounting.isTransitional)
        XCTAssertTrue(DriveState.ejecting.isTransitional)
        XCTAssertFalse(DriveState.mountedReadWrite.isTransitional)
        XCTAssertFalse(DriveState.notConnected.isTransitional)
    }

    func testEveryStateHasANonEmptyLabel() {
        let states: [DriveState] = [
            .notConnected, .detecting, .detected, .mountedReadOnly, .preparing, .mounting,
            .mountedReadWrite, .unmounting, .ejecting, .error(.diskNotFound(bsdName: "disk4s1")),
            .unsupportedFilesystem(.exfat), .unsafeToMount(reason: "test"), .dirtyFilesystem,
            .windowsHibernationDetected
        ]
        for state in states {
            XCTAssertFalse(state.label.isEmpty, "state \(state) has an empty label")
        }
    }

    func testDriveEligibilityRefusesInternalDisksAndTheBootVolume() {
        let base = Drive(
            bsdName: "disk4s1", volumeName: "Test", filesystem: .ntfs,
            capacityBytes: 1000, usedBytes: 0, freeBytes: 1000,
            isRemovable: true, isInternal: false, connectionType: .usb,
            mountPoint: nil, state: .detected
        )
        XCTAssertTrue(base.isEligibleForManagement)

        var internalDisk = base
        internalDisk.isInternal = true
        XCTAssertFalse(internalDisk.isEligibleForManagement)

        var bootVolume = base
        bootVolume.mountPoint = URL(fileURLWithPath: "/")
        XCTAssertFalse(bootVolume.isEligibleForManagement)
    }

    /// Regression test for the real-world bug this fix addresses: many
    /// external SSDs/HDDs report Disk Arbitration's "removable media" flag
    /// as false (that flag means media removable *from* a fixed drive
    /// mechanism — an optical tray, an SD slot — not "is this an external
    /// device"). Eligibility must not depend on it, or perfectly ordinary
    /// external drives get incorrectly refused as if they were internal.
    func testDriveEligibilityDoesNotRequireRemovableMediaFlag() {
        let nonRemovableExternalSSD = Drive(
            bsdName: "disk5s1", volumeName: "External SSD", filesystem: .ntfs,
            capacityBytes: 1_000_000_000_000, usedBytes: 0, freeBytes: 1_000_000_000_000,
            isRemovable: false, isInternal: false, connectionType: .usb,
            mountPoint: nil, state: .detected
        )
        XCTAssertTrue(nonRemovableExternalSSD.isEligibleForManagement)
    }
}
