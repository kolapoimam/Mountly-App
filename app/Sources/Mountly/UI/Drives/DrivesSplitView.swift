import SwiftUI
import MountlyCore

/// Master-detail layout for the Drives tab: a sidebar listing every
/// connected drive, and a detail pane showing the selected one in full.
struct DrivesSplitView: View {
    @EnvironmentObject private var driveStore: DriveStore
    @EnvironmentObject private var appState: AppState
    @State private var showOnboarding = false

    var body: some View {
        Group {
            if driveStore.drives.isEmpty {
                EmptyDrivesView(showOnboarding: $showOnboarding)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                NavigationSplitView {
                    sidebar
                } detail: {
                    if let drive = appState.selectedDrive {
                        DriveDetailView(drive: drive)
                            .id(drive.bsdName)
                    } else {
                        ContentUnavailableView("Select a Drive", systemImage: "externaldrive")
                    }
                }
                .navigationSplitViewColumnWidth(min: 260, ideal: 290, max: 340)
            }
        }
        .sheet(isPresented: $showOnboarding) {
            OnboardingView(isPresented: $showOnboarding)
        }
    }

    private var sidebar: some View {
        List(selection: $appState.selectedDriveBSDName) {
            Section {
                ForEach(driveStore.drives.sorted(by: { $0.volumeName < $1.volumeName })) { drive in
                    DriveSidebarRow(drive: drive)
                        .tag(drive.bsdName)
                }
            } header: {
                HStack {
                    Text("YOUR DRIVES")
                    Spacer()
                    Text("\(driveStore.drives.count) DETECTED")
                }
                .font(.mtCaption2)
            }
        }
        .listStyle(.sidebar)
        .safeAreaInset(edge: .bottom) {
            SidebarDiagnosticsFooter()
        }
        .onAppear {
            if appState.selectedDriveBSDName == nil {
                appState.selectedDriveBSDName = driveStore.drives.first?.bsdName
            }
        }
    }
}

/// Always-visible, real backend-status readout at the bottom of the
/// drives sidebar.
private struct SidebarDiagnosticsFooter: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider()
            row("Kernel extension", value: "Not required", valueColor: .primary)
            row("FUSE compatibility", value: appState.macFUSEInstalled ? "Verified" : "Not Installed",
                valueColor: appState.macFUSEInstalled ? .mtBlue : .secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.background)
    }

    private func row(_ label: String, value: String, valueColor: Color) -> some View {
        HStack {
            Text(label).font(.mtCaption2).foregroundStyle(.secondary)
            Spacer()
            Text(value).font(.mtCaption2).foregroundStyle(valueColor)
        }
    }
}

private struct EmptyDrivesView: View {
    @Binding var showOnboarding: Bool

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.mtBlue.opacity(0.12))
                    .frame(width: 96, height: 96)
                Image(systemName: "circle.dotted")
                    .font(.system(size: 40, weight: .light))
                    .foregroundStyle(.mtBlue)
            }
            Text("No external drives connected")
                .font(.mtTitle3)
            Text("Connect an external drive and Mountly\nwill detect it automatically.")
                .multilineTextAlignment(.center)
                .font(.mtBody)
                .foregroundStyle(.secondary)
            Text("Mountly supports multiple filesystems\nand external storage devices.")
                .multilineTextAlignment(.center)
                .font(.mtCallout)
                .foregroundStyle(.tertiary)
            Button("Learn how Mountly works") { showOnboarding = true }
                .buttonStyle(.bordered)
                .padding(.top, 6)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}
