import SwiftUI
import AppKit
import MountlyCore

/// The full detail panel for the selected drive — the primary place every
/// action happens (mount, eject, copy, diagnostics sheets). Fills the
/// NavigationSplitView detail pane, so it has no card chrome of its own.
struct DriveDetailView: View {
    let drive: Drive

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var driveStore: DriveStore
    @EnvironmentObject private var mountManager: MountManager
    @EnvironmentObject private var ejectManager: EjectManager
    @EnvironmentObject private var transferManager: TransferManager

    @State private var isWorking = false
    @State private var showLearnMore = false
    @State private var showBackendSetup = false
    @State private var showLimitedSupportDetails = false
    @State private var ejectBlockedCount: Int?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                header
                if drive.mountPoint != nil {
                    subtitleRow
                }
                if drive.capacityBytes > 0 {
                    capacitySection
                }
                statusSection
                actionRow
            }
            .padding(28)
            .frame(maxWidth: 720, alignment: .leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .sheet(isPresented: $showLearnMore) { LearnMoreSheet(state: drive.state) }
        .sheet(isPresented: $showBackendSetup) { BackendSetupView(isPresented: $showBackendSetup) }
        .sheet(isPresented: $showLimitedSupportDetails) { LimitedSupportSheet(filesystem: drive.filesystem) }
        .confirmationDialog(
            "Files are still being written to this drive.",
            isPresented: Binding(get: { ejectBlockedCount != nil }, set: { if !$0 { ejectBlockedCount = nil } }),
            titleVisibility: .visible
        ) {
            Button("Wait", role: .cancel) { ejectBlockedCount = nil }
            Button("Cancel Transfer & Eject", role: .destructive) {
                Task {
                    _ = await ejectManager.eject(bsdName: drive.bsdName, store: driveStore, force: true)
                    ejectBlockedCount = nil
                }
            }
        }
        .animation(.snappy(duration: 0.25), value: drive.state)
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(statusColor.opacity(0.16))
                    .frame(width: 48, height: 48)
                Image(systemName: MountlyTheme.driveSystemImage)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(statusColor)
            }
            .accessibilityHidden(true)

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(drive.volumeName).font(.mtTitle)
                FilesystemBadge(kind: drive.filesystem)
            }
            Spacer()
            statusPill
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(drive.volumeName), \(drive.filesystem.rawValue), \(drive.state.label)")
    }

    private var subtitleRow: some View {
        Text("\(drive.connectionType.rawValue) storage · Mounted at \(drive.mountPoint?.path ?? "")")
            .font(.mtCallout)
            .foregroundStyle(.secondary)
    }

    private var statusPill: some View {
        Label(drive.state.label, systemImage: MountlyTheme.statusSystemImage(for: drive.state))
            .font(.mtSubheadline)
            .foregroundStyle(statusColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Capsule().fill(statusColor.opacity(0.14)))
    }

    private var statusColor: Color { MountlyTheme.statusColor(for: drive.state) }

    // MARK: - Capacity

    private var capacitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(drive.capacityString).font(.mtLargeTitle)
                    Text("Total capacity").font(.mtCaption).foregroundStyle(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(drive.freeString) available").font(.mtBodyMedium)
                    Text("\(drive.usedString) used (\(percentUsed)%)").font(.mtCaption).foregroundStyle(.secondary)
                }
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(.quaternary)
                    Capsule().fill(statusColor.gradient).frame(width: geo.size.width * fractionUsed)
                }
            }
            .frame(height: 8)

            HStack(spacing: 16) {
                legendItem(color: statusColor, label: "Files & Data")
                legendItem(color: Color.secondary.opacity(0.5), label: "Free Space")
                Spacer()
                if let blockSize {
                    Text("\(clusterLabel): \(blockSize) bytes")
                        .font(.mtMonoCaption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 5) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text(label).font(.mtCaption2).foregroundStyle(.secondary)
        }
    }

    private var fractionUsed: Double {
        guard drive.capacityBytes > 0 else { return 0 }
        return min(max(Double(drive.usedBytes) / Double(drive.capacityBytes), 0), 1)
    }

    private var percentUsed: Int {
        Int((fractionUsed * 100).rounded())
    }

    private var clusterLabel: String {
        switch drive.filesystem {
        case .ntfs, .exfat, .fat32: return "Cluster size"
        default: return "Block size"
        }
    }

    private var blockSize: Int? {
        guard let path = drive.mountPoint?.path else { return nil }
        return VolumeInfo.blockSize(atPath: path)
    }

    // MARK: - Status detail

    @ViewBuilder
    private var statusSection: some View {
        switch drive.state {
        case .mountedReadWrite, .mountedReadOnly:
            mountedStatusCard
        case .error(let error):
            ErrorDetailView(error: error)
        case .unsafeToMount(let reason):
            explanationCard(title: "This drive needs attention", detail: reason, systemImage: "exclamationmark.triangle.fill")
        case .dirtyFilesystem:
            explanationCard(
                title: "Write access unavailable",
                detail: "This NTFS drive's filesystem journal wasn't cleanly closed, so Mountly is keeping it read-only to protect your files. Run a disk check (chkdsk) from Windows, or reconnect it after a clean Windows shutdown, then try again.",
                systemImage: "exclamationmark.triangle.fill"
            )
        case .windowsHibernationDetected:
            explanationCard(
                title: "Write access unavailable",
                detail: "This NTFS drive was not cleanly shut down by Windows. Connect it to Windows, disable hibernation/Fast Startup if necessary, then perform a full shutdown before reconnecting it to your Mac.",
                systemImage: "powersleep"
            )
        case .unsupportedFilesystem:
            explanationCard(
                title: "Mounting support unavailable",
                detail: "Mountly doesn't yet have safe read/write support for \(drive.filesystem.rawValue). This drive is detected but left untouched.",
                systemImage: "questionmark.circle.fill"
            )
        case .notConnected, .detecting, .detected, .preparing, .mounting, .unmounting, .ejecting:
            EmptyView()
        }
    }

    /// Every row here is a real, currently-true fact about this specific
    /// mount — never decorative. "Clean journal state" is valid here
    /// specifically because reaching `.mountedReadWrite`/`.mountedReadOnly`
    /// already means NTFS-3G/macOS itself didn't refuse the volume as
    /// dirty/hibernated (that produces `.dirtyFilesystem`/
    /// `.windowsHibernationDetected` instead — see `statusSection` above).
    private var mountedStatusCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            statusRow("Mounted with clean journal state", trailing: "Ready")
            if drive.writeVerified {
                statusRow("Write access verified via Mountly backend", trailing: "Active")
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(.background.secondary))
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).strokeBorder(.separator))
    }

    private func statusRow(_ text: String, trailing: String) -> some View {
        HStack {
            Image(systemName: "checkmark.circle.fill").foregroundStyle(.mtGreen)
            Text(text).font(.mtBody)
            Spacer()
            Text(trailing).font(.mtSubheadline).foregroundStyle(.mtGreen)
        }
    }

    private func explanationCard(title: String, detail: String, systemImage: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: systemImage)
                .font(.mtHeadline)
                .foregroundStyle(.mtOrange)
            Text(detail)
                .font(.mtCallout)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(.mtOrange.opacity(0.1)))
    }

    // MARK: - Actions

    @ViewBuilder
    private var actionRow: some View {
        HStack(spacing: 12) {
            switch drive.state {
            case .detected:
                Button("Enable Write Access") { enableReadWrite() }
                    .buttonStyle(.borderedProminent)
                    .tint(.mtBlue)
                    .disabled(isWorking)
                Button("Mount Read Only") { mountReadOnly() }
                    .disabled(isWorking)

            case .mountedReadOnly:
                Button("Enable Write Access") { enableReadWrite() }
                    .buttonStyle(.borderedProminent)
                    .tint(.mtBlue)
                    .disabled(isWorking)
                openInFinderButton
                Spacer()
                ejectButton

            case .mountedReadWrite:
                openInFinderButton
                Button("Copy to Drive…") { copyToDrive() }
                Button("Copy from Drive…") { copyFromDrive() }
                Menu {
                    Button("New Folder") { createFolder() }
                    Button("Reveal in Finder") { openInFinder() }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .menuStyle(.borderlessButton)
                .frame(width: 28)
                .accessibilityLabel("More actions")
                Spacer()
                ejectButton

            case .windowsHibernationDetected, .dirtyFilesystem:
                Button("Mount Read-Only") { mountReadOnly() }
                Button("How to fix this") { showLearnMore = true }

            case .error(let error):
                if case .backendNotInstalled = error {
                    Button("Set Up") { showBackendSetup = true }
                        .buttonStyle(.borderedProminent)
                        .tint(.mtBlue)
                } else if case .helperApprovalRequired = error {
                    Button("Open System Settings") { appState.openHelperApprovalSettings() }
                        .buttonStyle(.borderedProminent)
                        .tint(.mtBlue)
                    Button("Try Again") { enableReadWrite() }
                        .disabled(isWorking)
                } else {
                    Button("Try Again") { enableReadWrite() }
                        .disabled(isWorking)
                }
                Button("Copy Technical Details") { copyTechnicalDetails(error) }

            case .unsupportedFilesystem:
                Button("View Details") { showLimitedSupportDetails = true }

            case .unsafeToMount:
                Button("How to fix this") { showLearnMore = true }

            case .notConnected, .detecting, .preparing, .mounting, .unmounting, .ejecting:
                ProgressView().controlSize(.small)
                Text(drive.state.label).font(.mtCallout).foregroundStyle(.secondary)
            }
        }
        .controlSize(.regular)
    }

    private var openInFinderButton: some View {
        Button {
            openInFinder()
        } label: {
            Label("Open in Finder", systemImage: "folder")
        }
        .buttonStyle(.bordered)
    }

    private var ejectButton: some View {
        Button(role: .destructive) {
            eject()
        } label: {
            Label("Eject Volume", systemImage: "eject")
        }
        .buttonStyle(.plain)
        .foregroundStyle(.mtBlue)
        .font(.mtBodyMedium)
    }

    // MARK: - Actions implementation

    private func enableReadWrite() {
        isWorking = true
        Task {
            await mountManager.enableReadWrite(for: drive.bsdName, store: driveStore)
            isWorking = false
        }
    }

    private func mountReadOnly() {
        isWorking = true
        Task {
            await mountManager.mountReadOnly(for: drive.bsdName, store: driveStore)
            isWorking = false
        }
    }

    private func eject() {
        Task {
            let outcome = await ejectManager.eject(bsdName: drive.bsdName, store: driveStore)
            if case .blockedByActiveTransfers(let count) = outcome {
                ejectBlockedCount = count
            }
        }
    }

    private func openInFinder() {
        guard let mountPoint = drive.mountPoint else { return }
        NSWorkspace.shared.open(mountPoint)
    }

    private func createFolder() {
        guard let mountPoint = drive.mountPoint else { return }
        let panel = NSAlert()
        panel.messageText = "New Folder"
        panel.addButton(withTitle: "Create")
        panel.addButton(withTitle: "Cancel")
        let field = NSTextField(frame: NSRect(x: 0, y: 0, width: 220, height: 24))
        field.stringValue = "Untitled Folder"
        panel.accessoryView = field
        if panel.runModal() == .alertFirstButtonReturn {
            let name = field.stringValue.isEmpty ? "Untitled Folder" : field.stringValue
            try? FileManager.default.createDirectory(at: mountPoint.appendingPathComponent(name), withIntermediateDirectories: false)
        }
    }

    private func copyToDrive() {
        guard let mountPoint = drive.mountPoint else { return }
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = true
        panel.message = "Choose files or folders to copy to \(drive.volumeName)"
        guard panel.runModal() == .OK else { return }
        let items = panel.urls.map {
            TransferFileItem(sourceURL: $0, destinationURL: mountPoint.appendingPathComponent($0.lastPathComponent), sizeBytes: fileSize($0))
        }
        transferManager.startCopy(files: items, direction: .macToDrive, conflictResolver: { url in
            await ConflictPrompt.resolve(destination: url)
        })
    }

    private func copyFromDrive() {
        guard let mountPoint = drive.mountPoint else { return }
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = true
        openPanel.directoryURL = mountPoint
        openPanel.message = "Choose files or folders to copy from \(drive.volumeName)"
        guard openPanel.runModal() == .OK else { return }

        let savePanel = NSOpenPanel()
        savePanel.canChooseDirectories = true
        savePanel.canChooseFiles = false
        savePanel.message = "Choose a destination on your Mac"
        guard savePanel.runModal() == .OK, let destinationDir = savePanel.url else { return }

        let items = openPanel.urls.map {
            TransferFileItem(sourceURL: $0, destinationURL: destinationDir.appendingPathComponent($0.lastPathComponent), sizeBytes: fileSize($0))
        }
        transferManager.startCopy(files: items, direction: .driveToMac, conflictResolver: { url in
            await ConflictPrompt.resolve(destination: url)
        })
    }

    private func copyTechnicalDetails(_ error: TMError) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString("\(error.reason)\n\(error.explanation)\n\(error.technicalDetail)", forType: .string)
    }

    private func fileSize(_ url: URL) -> Int64 {
        (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int64) ?? 0
    }
}
