import SwiftUI
import MountlyCore

/// Settings window.
struct SettingsView: View {
    @EnvironmentObject private var settings: SettingsStore

    var body: some View {
        TabView {
            GeneralSettingsTab().tabItem { Label("General", systemImage: "gearshape") }
            MountingSettingsTab().tabItem { Label("Mounting", systemImage: "externaldrive") }
            NotificationsSettingsTab().tabItem { Label("Notifications", systemImage: "bell") }
            AppearanceSettingsTab().tabItem { Label("Appearance", systemImage: "paintpalette") }
            SafetySettingsTab().tabItem { Label("Safety", systemImage: "lock.shield") }
            AdvancedSettingsTab().tabItem { Label("Advanced", systemImage: "wrench.and.screwdriver") }
        }
        .environmentObject(settings)
        .padding(20)
    }
}

private struct GeneralSettingsTab: View {
    @EnvironmentObject private var settings: SettingsStore
    var body: some View {
        Form {
            Toggle("Launch at login", isOn: $settings.launchAtLogin)
            Toggle("Show menu bar icon", isOn: $settings.showMenuBarIcon)
            Toggle("Automatically detect drives", isOn: $settings.automaticallyDetectDrives)
            Toggle("Automatically mount supported drives", isOn: $settings.automaticallyMountSupportedDrives)
        }
    }
}

private struct MountingSettingsTab: View {
    @EnvironmentObject private var settings: SettingsStore
    var body: some View {
        Form {
            Picker("Default mount mode", selection: $settings.defaultMountModeIsReadWrite) {
                Text("Read Only").tag(false)
                Text("Read & Write").tag(true)
            }
            Toggle("Verify write access after mounting", isOn: $settings.verifyWriteAccess)
                .disabled(true)
                .help("Write verification is a core safety guarantee and cannot be disabled.")
        }
    }
}

private struct NotificationsSettingsTab: View {
    @EnvironmentObject private var settings: SettingsStore
    var body: some View {
        Form {
            Toggle("Drive connected", isOn: $settings.notifyDriveConnected)
            Toggle("Drive mounted", isOn: $settings.notifyDriveMounted)
            Toggle("Drive disconnected", isOn: $settings.notifyDriveDisconnected)
            Toggle("Mount errors", isOn: $settings.notifyMountErrors)
        }
    }
}

private struct AppearanceSettingsTab: View {
    @EnvironmentObject private var settings: SettingsStore
    var body: some View {
        Form {
            Picker("Appearance", selection: $settings.appearanceMode) {
                ForEach(AppearanceMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.inline)
        }
    }
}

private struct AdvancedSettingsTab: View {
    @EnvironmentObject private var settings: SettingsStore
    var body: some View {
        Form {
            Toggle("Diagnostic logging", isOn: $settings.diagnosticLoggingEnabled)
            Toggle("Debug mode", isOn: $settings.debugMode)
            Text("See the Diagnostics tab in the main window for backend information and mount point details.")
                .font(.mtCaption)
                .foregroundStyle(.secondary)
        }
    }
}

private struct SafetySettingsTab: View {
    @EnvironmentObject private var settings: SettingsStore
    var body: some View {
        Form {
            Toggle("Require confirmation before eject", isOn: $settings.requireConfirmationBeforeEject)
            Toggle("Require confirmation before destructive file operations", isOn: $settings.requireConfirmationBeforeDestructiveOps)
        }
    }
}
