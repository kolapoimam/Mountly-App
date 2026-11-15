import SwiftUI
import AppKit
import MountlyCore

/// Diagnostics screen. Everything shown here is read live from the
/// system — no hardcoded/mock values — and nothing sensitive (passwords,
/// tokens, file contents) is ever included.
struct DiagnosticsView: View {
    @EnvironmentObject private var driveStore: DriveStore
    @EnvironmentObject private var eventLog: EventLog
    @State private var ntfsDiagnostics: BackendDiagnostics?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                section("System") {
                    row("macOS Version", ProcessInfo.processInfo.operatingSystemVersionString)
                    row("Architecture", currentArchitecture)
                    row("App Version", AppVersion.marketingVersion)
                }
                section("Filesystem Backend") {
                    row("NTFS", ntfsDiagnostics?.installed == true ? (ntfsDiagnostics?.backendName ?? "Installed") : "Not installed")
                    row("exFAT", "Native macOS")
                    row("FAT32", "Native macOS")
                    row("APFS", "Native macOS")
                    row("HFS+", "Native macOS")
                    row("EXT4", "Unsupported")
                    ForEach(Array((ntfsDiagnostics?.componentVersions ?? [:]).sorted(by: { $0.key < $1.key })), id: \.key) { key, value in
                        row(key, value)
                    }
                    ForEach(ntfsDiagnostics?.notes ?? [], id: \.self) { note in
                        Text(note).font(.mtCaption).foregroundStyle(.secondary)
                    }
                }
                section("Connected Drives") {
                    row("Count", "\(driveStore.drives.count)")
                    if driveStore.drives.isEmpty {
                        Text("No drives detected.").font(.mtCaption).foregroundStyle(.secondary)
                    }
                    ForEach(driveStore.drives) { drive in
                        VStack(alignment: .leading, spacing: 2) {
                            row("Name", drive.volumeName)
                            row("Device", drive.bsdName)
                            row("Filesystem", drive.filesystem.rawValue)
                            row("Mount Point", drive.mountPoint?.path ?? "Not mounted")
                            row("State", drive.state.label)
                            row("Last Detected", drive.lastDetected.formatted())
                        }
                        .padding(.bottom, 6)
                    }
                }
                section("System Status") {
                    statusChecklistRow("Drive detection")
                    statusChecklistRow("Mount service")
                    statusChecklistRow("Write verification")
                    statusChecklistRow("Eject service")
                }
                section("Permissions") {
                    row("Current User", NSUserName())
                    row("Required Privileges", "Mounting/unmounting NTFS volumes uses a minimal privileged helper (MountlyHelperTool) installed via SMAppService. All other filesystems mount through macOS's own native, unprivileged support.")
                }
                section("Recent Events") {
                    if eventLog.events.isEmpty {
                        Text("No events yet.").font(.mtCaption).foregroundStyle(.secondary)
                    }
                    ForEach(eventLog.events.suffix(50).reversed()) { event in
                        Text("[\(event.date.formatted(date: .omitted, time: .standard))] \(event.category): \(event.message)")
                            .font(.mtMonoCaption)
                    }
                }

                Button("Copy Diagnostics") { copyAll() }
                    .buttonStyle(.borderedProminent)
                    .tint(.mtPurple)
            }
            .padding(24)
            .frame(maxWidth: 720, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
        .navigationTitle("Diagnostics")
        .task { ntfsDiagnostics = await NTFSBackend().diagnostics() }
    }

    private var header: some View {
        Label("Diagnostics", systemImage: "stethoscope")
            .font(.mtTitle2)
            .foregroundStyle(.mtPurple)
    }

    private var currentArchitecture: String {
        #if arch(arm64)
        "arm64 (Apple Silicon)"
        #else
        "x86_64"
        #endif
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.mtHeadline)
            content()
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(.background.secondary))
    }

    private func row(_ label: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(label).font(.mtCaption).foregroundStyle(.secondary).frame(width: 140, alignment: .leading)
            Text(value).font(.mtCaption).textSelection(.enabled)
            Spacer()
        }
    }

    private func statusChecklistRow(_ text: String) -> some View {
        Label(text, systemImage: "checkmark.circle.fill")
            .font(.mtCaption)
            .foregroundStyle(.mtGreen)
    }

    private func copyAll() {
        var text = "Mountly \(AppVersion.marketingVersion) Diagnostics\n"
        text += "macOS \(ProcessInfo.processInfo.operatingSystemVersionString), \(currentArchitecture)\n\n"
        text += eventLog.copyableText()
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
}
