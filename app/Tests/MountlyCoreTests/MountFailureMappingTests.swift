import XCTest
@testable import MountlyCore

/// Verifies the mapping from raw NTFS-3G stderr text to the specific
/// safety states the app uses. This is the single most important safety-facing
/// piece of logic in the app, since a mismapped hibernation/dirty state
/// could let the UI imply write access is fine when it isn't.
final class MountFailureMappingTests: XCTestCase {
    func testHibernationTextMapsToHibernationState() {
        let error = TMError.mountFailed(technicalDetail: "Windows is hibernated, refused to mount.")
        XCTAssertEqual(MountManager.mapKnownFailure(error), .windowsHibernationDetected)
    }

    func testDirtyVolumeTextMapsToDirtyFilesystemState() {
        let error = TMError.mountFailed(technicalDetail: "Volume is scheduled for a check, please run chkdsk.")
        XCTAssertEqual(MountManager.mapKnownFailure(error), .dirtyFilesystem)
    }

    func testUnrelatedFailureTextMapsToGenericError() {
        let error = TMError.mountFailed(technicalDetail: "device busy")
        XCTAssertEqual(MountManager.mapKnownFailure(error), .error(error))
    }

    func testNonMountFailedErrorsPassThroughUnchanged() {
        let error = TMError.backendNotInstalled
        XCTAssertEqual(MountManager.mapKnownFailure(error), .error(error))
    }
}
