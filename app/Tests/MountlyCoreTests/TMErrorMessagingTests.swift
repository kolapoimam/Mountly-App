import XCTest
@testable import MountlyCore

/// Mountly requires human-readable errors, never a raw exit code as the
/// headline. This asserts every case actually produces prose, and that the
/// "headline" specifically never looks like a bare process exit message.
final class TMErrorMessagingTests: XCTestCase {
    private static let sampleErrors: [TMError] = [
        .backendNotInstalled,
        .backendInstallFailed(technicalDetail: "exit code 1"),
        .diskNotFound(bsdName: "disk4s1"),
        .unexpectedFilesystem(actual: .exfat),
        .unsafeWindowsState,
        .mountFailed(technicalDetail: "mount_ntfs-3g exited with code 1"),
        .writeVerificationFailed(technicalDetail: "probe failed"),
        .alreadyMounted,
        .unmountFailed(technicalDetail: "resource busy"),
        .transfersInProgress(count: 2),
        .fileAlreadyExists(name: "photo.jpg"),
        .sourceUnreadable(technicalDetail: "permission denied"),
        .destinationFull,
        .driveDisconnectedDuringOperation,
        .privilegedHelperUnavailable,
        .helperApprovalRequired,
        .internalDiskRefused,
        .bootVolumeRefused
    ]

    func testEveryErrorHasNonEmptyUserFacingText() {
        for error in Self.sampleErrors {
            XCTAssertFalse(error.reason.isEmpty, "\(error) missing reason")
            XCTAssertFalse(error.explanation.isEmpty, "\(error) missing explanation")
            XCTAssertFalse(error.recommendedAction.isEmpty, "\(error) missing recommendedAction")
        }
    }

    func testHeadlineReasonNeverLooksLikeARawExitCode() {
        for error in Self.sampleErrors {
            XCTAssertFalse(error.reason.lowercased().contains("exit code"), "\(error) leaks a raw exit code into the headline")
            XCTAssertFalse(error.reason.lowercased().contains("mount_ntfs"), "\(error) leaks a raw command name into the headline")
        }
    }

    func testTransferInProgressPluralizesCorrectly() {
        XCTAssertTrue(TMError.transfersInProgress(count: 1).reason.contains("A file"))
        XCTAssertTrue(TMError.transfersInProgress(count: 3).reason.contains("3 files"))
    }

    /// Regression test: `technicalDetail` used to both truncate
    /// `String(describing: self)` to 64 characters *and* append the same
    /// detail again in full, producing a doubled, garbled string for any
    /// long underlying error (exactly what a real NTFS-3G multi-line
    /// refusal message triggered in practice). It must now appear exactly
    /// once.
    func testTechnicalDetailNeverDuplicatesTheUnderlyingDetail() {
        let longDetail = """
        helperReturnedFailure("Error opening '/dev/rdisk13s1': Operation not permitted
        Failed to mount '/dev/rdisk13s1': Operation not permitted
        The NTFS partition is in an unsafe state.")
        """
        let error = TMError.mountFailed(technicalDetail: longDetail)
        let occurrences = error.technicalDetail.components(separatedBy: "Error opening").count - 1
        XCTAssertEqual(occurrences, 1, "the detail text must appear exactly once, not duplicated: \(error.technicalDetail)")
    }

    /// The user-facing `explanation` (and `reason`) must always be plain
    /// language with a next step — never the raw system/process output.
    /// That raw text belongs only in `technicalDetail`, behind "Copy
    /// Technical Details". A real NTFS-3G refusal message like the one
    /// below used to leak straight into `explanation` via a literal
    /// "Technical detail: <raw text>" pattern; this locks in that it no
    /// longer does, for every case that carries a raw detail string.
    func testExplanationNeverLeaksRawTechnicalDetail() {
        let rawDetail = "helperReturnedFailure(\"Error opening '/dev/rdisk13s1': Operation not permitted\")"
        let casesWithDetail: [TMError] = [
            .backendInstallFailed(technicalDetail: rawDetail),
            .mountFailed(technicalDetail: rawDetail),
            .writeVerificationFailed(technicalDetail: rawDetail),
            .unmountFailed(technicalDetail: rawDetail),
            .sourceUnreadable(technicalDetail: rawDetail)
        ]
        for error in casesWithDetail {
            XCTAssertFalse(error.explanation.contains(rawDetail), "\(error) leaks its raw technical detail into the user-facing explanation")
            XCTAssertFalse(error.explanation.lowercased().contains("technical detail"), "\(error) still references 'technical detail' inline instead of keeping it in a separate field")
            // The raw detail must still be fully recoverable via technicalDetail.
            XCTAssertTrue(error.technicalDetail.contains(rawDetail), "\(error) lost its technical detail entirely")
        }
    }
}
