import Foundation

/// Appearance override for the app — System follows macOS.
public enum AppearanceMode: String, Sendable, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
}

/// Backing store for the Settings window. A thin, testable wrapper
/// over `UserDefaults` — the SwiftUI Settings screens bind directly to
/// these published properties.
@MainActor
public final class SettingsStore: ObservableObject {
    public static let shared = SettingsStore()

    private let defaults: UserDefaults

    // General
    @Published public var launchAtLogin: Bool { didSet { defaults.set(launchAtLogin, forKey: Keys.launchAtLogin) } }
    @Published public var showMenuBarIcon: Bool { didSet { defaults.set(showMenuBarIcon, forKey: Keys.showMenuBarIcon) } }
    @Published public var automaticallyDetectDrives: Bool { didSet { defaults.set(automaticallyDetectDrives, forKey: Keys.autoDetect) } }

    // Mounting
    @Published public var automaticallyMountSupportedDrives: Bool { didSet { defaults.set(automaticallyMountSupportedDrives, forKey: Keys.autoMount) } }
    @Published public var defaultMountModeIsReadWrite: Bool { didSet { defaults.set(defaultMountModeIsReadWrite, forKey: Keys.defaultMountMode) } }
    @Published public var verifyWriteAccess: Bool { didSet { defaults.set(verifyWriteAccess, forKey: Keys.verifyWriteAccess) } }

    // Notifications
    @Published public var notifyDriveConnected: Bool { didSet { defaults.set(notifyDriveConnected, forKey: Keys.notifyConnected) } }
    @Published public var notifyDriveMounted: Bool { didSet { defaults.set(notifyDriveMounted, forKey: Keys.notifyMounted) } }
    @Published public var notifyDriveDisconnected: Bool { didSet { defaults.set(notifyDriveDisconnected, forKey: Keys.notifyDisconnected) } }
    @Published public var notifyMountErrors: Bool { didSet { defaults.set(notifyMountErrors, forKey: Keys.notifyErrors) } }

    // Advanced
    @Published public var diagnosticLoggingEnabled: Bool { didSet { defaults.set(diagnosticLoggingEnabled, forKey: Keys.diagnosticLogging) } }
    @Published public var debugMode: Bool { didSet { defaults.set(debugMode, forKey: Keys.debugMode) } }

    // Safety
    @Published public var requireConfirmationBeforeEject: Bool { didSet { defaults.set(requireConfirmationBeforeEject, forKey: Keys.confirmEject) } }
    @Published public var requireConfirmationBeforeDestructiveOps: Bool { didSet { defaults.set(requireConfirmationBeforeDestructiveOps, forKey: Keys.confirmDestructive) } }

    // Appearance
    @Published public var appearanceMode: AppearanceMode { didSet { defaults.set(appearanceMode.rawValue, forKey: Keys.appearanceMode) } }

    private enum Keys {
        static let launchAtLogin = "launchAtLogin"
        static let showMenuBarIcon = "showMenuBarIcon"
        static let autoDetect = "automaticallyDetectDrives"
        static let autoMount = "automaticallyMountSupportedDrives"
        static let defaultMountMode = "defaultMountModeIsReadWrite"
        static let verifyWriteAccess = "verifyWriteAccess"
        static let notifyConnected = "notifyDriveConnected"
        static let notifyMounted = "notifyDriveMounted"
        static let notifyDisconnected = "notifyDriveDisconnected"
        static let notifyErrors = "notifyMountErrors"
        static let diagnosticLogging = "diagnosticLoggingEnabled"
        static let debugMode = "debugMode"
        static let confirmEject = "requireConfirmationBeforeEject"
        static let confirmDestructive = "requireConfirmationBeforeDestructiveOps"
        static let appearanceMode = "appearanceMode"
    }

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.launchAtLogin = defaults.object(forKey: Keys.launchAtLogin) as? Bool ?? false
        self.showMenuBarIcon = defaults.object(forKey: Keys.showMenuBarIcon) as? Bool ?? true
        self.automaticallyDetectDrives = defaults.object(forKey: Keys.autoDetect) as? Bool ?? true
        // Automatic mounting defaults OFF until the implementation
        // can guarantee safe behaviour end-to-end for a given user.
        self.automaticallyMountSupportedDrives = defaults.object(forKey: Keys.autoMount) as? Bool ?? false
        self.defaultMountModeIsReadWrite = defaults.object(forKey: Keys.defaultMountMode) as? Bool ?? false
        self.verifyWriteAccess = defaults.object(forKey: Keys.verifyWriteAccess) as? Bool ?? true
        self.notifyDriveConnected = defaults.object(forKey: Keys.notifyConnected) as? Bool ?? true
        self.notifyDriveMounted = defaults.object(forKey: Keys.notifyMounted) as? Bool ?? true
        self.notifyDriveDisconnected = defaults.object(forKey: Keys.notifyDisconnected) as? Bool ?? true
        self.notifyMountErrors = defaults.object(forKey: Keys.notifyErrors) as? Bool ?? true
        self.diagnosticLoggingEnabled = defaults.object(forKey: Keys.diagnosticLogging) as? Bool ?? true
        self.debugMode = defaults.object(forKey: Keys.debugMode) as? Bool ?? false
        self.requireConfirmationBeforeEject = defaults.object(forKey: Keys.confirmEject) as? Bool ?? true
        self.requireConfirmationBeforeDestructiveOps = defaults.object(forKey: Keys.confirmDestructive) as? Bool ?? true
        self.appearanceMode = (defaults.string(forKey: Keys.appearanceMode)).flatMap(AppearanceMode.init) ?? .system
    }
}
