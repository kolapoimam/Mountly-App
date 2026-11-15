import SwiftUI
import MountlyCore

/// A small, distinctly-tinted capsule per filesystem type. `compact`
/// shrinks it for dense contexts like the drives sidebar.
struct FilesystemBadge: View {
    let kind: FilesystemKind
    var compact: Bool = false

    var body: some View {
        Text(kind.rawValue)
            .font(compact ? .mtCaption2 : .mtCaption)
            .foregroundStyle(MountlyTheme.filesystemColor(for: kind))
            .padding(.horizontal, compact ? 6 : 8)
            .padding(.vertical, compact ? 2 : 3)
            .background(Capsule().fill(MountlyTheme.filesystemColor(for: kind).opacity(0.14)))
    }
}

struct ErrorDetailView: View {
    let error: TMError

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(error.reason, systemImage: "xmark.octagon.fill")
                .font(.mtHeadline)
                .foregroundStyle(.mtRed)
            Text(error.explanation)
                .font(.mtCallout)
                .foregroundStyle(.secondary)
            Text(error.recommendedAction)
                .font(.mtBodyMedium)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(.mtRed.opacity(0.08)))
    }
}

struct LearnMoreSheet: View {
    let state: DriveState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("How to fix this", systemImage: "wrench.and.screwdriver.fill")
                .font(.mtTitle3)
                .foregroundStyle(.mtOrange)
            Text(whatsWrong)
                .font(.mtBody)
                .fixedSize(horizontal: false, vertical: true)
            VStack(alignment: .leading, spacing: 6) {
                Text("What to do")
                    .font(.mtHeadline)
                Text(fix)
                    .font(.mtBody)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Text("Mountly will never attempt to repair or force-mount a volume in this state — that risk is not worth taking with your files.")
                .font(.mtCallout)
                .foregroundStyle(.secondary)
            Spacer()
            HStack {
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
        .frame(width: 440, height: 340)
    }

    private var whatsWrong: String {
        switch state {
        case .windowsHibernationDetected:
            return "This NTFS drive was not cleanly shut down by Windows. Fast Startup and hibernation both leave the volume's internal journal in a state that isn't fully consistent — mounting it read/write from macOS in that state risks corrupting files."
        case .dirtyFilesystem:
            return "This drive is flagged as not cleanly unmounted (\"dirty\"). Windows normally runs a consistency check (chkdsk) on volumes in this state, and Mountly doesn't attempt filesystem repair itself — only Windows' own chkdsk should do that."
        default:
            return "This drive is currently in a state where enabling write access isn't safe."
        }
    }

    private var fix: String {
        switch state {
        case .windowsHibernationDetected:
            return "Connect the drive to Windows, disable hibernation/Fast Startup if necessary, then perform a full shutdown (not sleep) before reconnecting it to your Mac."
        case .dirtyFilesystem:
            return "Connect the drive to Windows and run \"chkdsk /f\" on it (or let Windows run its own disk-check prompt), then reconnect it to your Mac."
        default:
            return "Reconnect the drive after a clean shutdown, or use Mount Read-Only for now."
        }
    }
}

struct LimitedSupportSheet: View {
    let filesystem: FilesystemKind
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Detected — Limited Support", systemImage: "questionmark.circle.fill")
                .font(.mtTitle3)
                .foregroundStyle(.mtOrange)
            Text("This drive is formatted as \(filesystem.rawValue). Mountly detects it, but doesn't have a safe, actively-maintained read/write driver for it on macOS yet.")
                .font(.mtBody)
                .fixedSize(horizontal: false, vertical: true)
            Text("Mountly never fakes support for a filesystem — if it can't verify real read/write access, it says so plainly instead of guessing.")
                .font(.mtCallout)
                .foregroundStyle(.secondary)
            Spacer()
            HStack {
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
        .frame(width: 420, height: 260)
    }
}
