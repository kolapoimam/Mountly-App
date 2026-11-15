import Foundation
import ServiceManagement

/// Registers `MountlyHelperTool` with launchd via `SMAppService.daemon` —
/// the step that was documented in `docs/ARCHITECTURE.md`/`SECURITY.md`
/// but never actually implemented, which is why `HelperClient` could never
/// reach the helper (every mach-service connection failed with
/// `connectionFailed`, since nothing had ever told launchd the service
/// existed). This is the one place that calls `register()`.
public enum HelperRegistrar {
    public static let plistName = "com.mountly.app.helper.plist"

    public enum RegistrationOutcome: Sendable, Equatable {
        case alreadyRegistered
        case registered
        /// The daemon is registered but the user must approve it once in
        /// System Settings → General → Login Items & Extensions before
        /// launchd will actually run it.
        case requiresApproval
        case failed(String)
    }

    public static func currentStatus() -> SMAppService.Status {
        SMAppService.daemon(plistName: plistName).status
    }

    @discardableResult
    public static func registerIfNeeded() -> RegistrationOutcome {
        let service = SMAppService.daemon(plistName: plistName)
        switch service.status {
        case .enabled:
            return .alreadyRegistered
        case .requiresApproval:
            return .requiresApproval
        case .notRegistered, .notFound:
            do {
                try service.register()
                return service.status == .requiresApproval ? .requiresApproval : .registered
            } catch {
                return .failed(String(describing: error))
            }
        @unknown default:
            return .failed("unknown SMAppService status")
        }
    }

    /// Deep-links directly to the Login Items & Extensions pane so the
    /// user doesn't have to hunt for the approval toggle themselves.
    public static func openSystemSettingsLoginItems() {
        SMAppService.openSystemSettingsLoginItems()
    }
}
