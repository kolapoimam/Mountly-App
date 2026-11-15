import SwiftUI
import MountlyCore

@main
struct MountlyApp: App {
    @StateObject private var appState = AppState()

    init() {
        FontRegistrar.registerBundledFontsIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(appState.driveStore)
                .environmentObject(appState.mountManager)
                .environmentObject(appState.ejectManager)
                .environmentObject(appState.transferManager)
                .environmentObject(appState.settings)
                .environmentObject(appState.eventLog)
                .frame(minWidth: 860, minHeight: 580)
                .task { appState.start() }
                .preferredColorScheme(preferredColorScheme)
        }
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) {}
            CommandGroup(replacing: .appInfo) {
                AboutMenuButton()
            }
        }

        Window("About Mountly", id: "about") {
            AboutView()
        }
        .windowResizability(.contentSize)

        MenuBarExtra("Mountly", systemImage: "externaldrive.connected.to.line.below") {
            MenuBarView()
                .environmentObject(appState)
                .environmentObject(appState.driveStore)
                .environmentObject(appState.mountManager)
                .environmentObject(appState.ejectManager)
                .environmentObject(appState.settings)
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
                .environmentObject(appState.settings)
                .frame(width: 520, height: 460)
        }
    }

    private var preferredColorScheme: ColorScheme? {
        switch appState.settings.appearanceMode {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}
