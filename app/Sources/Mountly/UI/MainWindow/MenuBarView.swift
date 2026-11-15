import SwiftUI
import AppKit
import MountlyCore

/// Menu bar extra content.
struct MenuBarView: View {
    @EnvironmentObject private var driveStore: DriveStore
    @EnvironmentObject private var ejectManager: EjectManager
    @Environment(\.openSettings) private var openSettings
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "externaldrive.connected.to.line.below")
                    .foregroundStyle(.mtBlue)
                Text("Mountly").font(.mtHeadline)
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)
            .padding(.bottom, 8)

            if driveStore.drives.isEmpty {
                Text("No compatible drives connected.")
                    .font(.mtSubheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 14)
                    .padding(.bottom, 10)
            } else {
                Text("Connected Drives")
                    .font(.mtCaption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 14)
                    .padding(.bottom, 4)
                ForEach(driveStore.drives) { drive in
                    driveRow(drive)
                }
            }

            Divider().padding(.vertical, 6)

            menuButton("Open Mountly") { activateMainWindow() }
            if hasAnyMounted {
                menuButton("Eject All Safely") { ejectAll() }
            }

            Divider().padding(.vertical, 6)

            menuButton("Settings…") { openSettings() }
            menuButton("Diagnostics…") { activateMainWindow() }
            menuButton("About Mountly") { openWindow(id: "about") }

            Divider().padding(.vertical, 6)

            menuButton("Quit") { NSApplication.shared.terminate(nil) }
                .padding(.bottom, 10)
        }
        .frame(width: 300)
    }

    private var hasAnyMounted: Bool {
        driveStore.drives.contains { $0.mountPoint != nil }
    }

    private func driveRow(_ drive: Drive) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Circle()
                    .fill(MountlyTheme.statusColor(for: drive.state))
                    .frame(width: 8, height: 8)
                Text(drive.volumeName).font(.mtSubheadline)
                Spacer()
                FilesystemBadge(kind: drive.filesystem)
            }
            Text(drive.state.label)
                .font(.mtCaption)
                .foregroundStyle(MountlyTheme.statusColor(for: drive.state))
            HStack(spacing: 12) {
                if let mountPoint = drive.mountPoint {
                    menuButton("Open in Finder", small: true) { NSWorkspace.shared.open(mountPoint) }
                    menuButton("Eject", small: true) {
                        Task { _ = await ejectManager.eject(bsdName: drive.bsdName, store: driveStore) }
                    }
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
    }

    private func menuButton(_ title: String, small: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(small ? .mtCaption : .mtBody)
                .frame(maxWidth: small ? nil : .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, small ? 0 : 14)
        .padding(.vertical, small ? 0 : 3)
    }

    private func activateMainWindow() {
        NSApp.activate(ignoringOtherApps: true)
        for window in NSApp.windows where window.title == "Mountly" {
            window.makeKeyAndOrderFront(nil)
        }
    }

    /// Attempts to eject every mounted drive. Any drive with an active
    /// transfer is safely skipped (never force-ejected from this bulk
    /// action) — its card in the main window still shows why.
    private func ejectAll() {
        for drive in driveStore.drives where drive.mountPoint != nil {
            let bsdName = drive.bsdName
            Task { _ = await ejectManager.eject(bsdName: bsdName, store: driveStore) }
        }
    }
}
