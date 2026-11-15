import XCTest
@testable import MountlyCore

/// `HelperRegistrar` talks to real launchd/SMAppService state, so there's
/// limited value in deep unit testing here (the previous bug — this class
/// existing at all — was exactly that `SMAppService.daemon(...).register()`
/// was never called anywhere, which no unit test would have caught since
/// it's an integration-level gap, not a logic bug). This just confirms the
/// API surface is callable and doesn't crash when run outside a proper
/// signed .app bundle (e.g. under `swift test`), which is itself useful
/// coverage: `SMAppService` must degrade to `.notFound`/`.failed`
/// gracefully in that environment rather than trapping.
final class HelperRegistrarTests: XCTestCase {
    func testPlistNameMatchesTheEmbeddedLaunchdPlist() {
        XCTAssertEqual(HelperRegistrar.plistName, "com.mountly.app.helper.plist")
    }

    func testCurrentStatusAndRegisterIfNeededDoNotCrashOutsideAnAppBundle() {
        _ = HelperRegistrar.currentStatus()
        let outcome = HelperRegistrar.registerIfNeeded()
        switch outcome {
        case .alreadyRegistered, .registered, .requiresApproval, .failed:
            break // any of these is a valid, non-crashing outcome here.
        }
    }
}
