import SwiftUI
import MountlyCore

/// One compact row in the drives sidebar — presentation only; all actions
/// live in `DriveDetailView` for the selected drive.
struct DriveSidebarRow: View {
    let drive: Drive

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(statusColor.opacity(0.16))
                    .frame(width: 34, height: 34)
                Image(systemName: MountlyTheme.driveSystemImage)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(statusColor)
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(drive.volumeName)
                        .font(.mtBodyMedium)
                        .lineLimit(1)
                    FilesystemBadge(kind: drive.filesystem, compact: true)
                }
                Text(drive.capacityBytes > 0 ? drive.capacityString : drive.filesystem.rawValue)
                    .font(.mtCaption2)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 4)

            Text(sidebarStatusText)
                .font(.mtCaption2)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(drive.volumeName), \(drive.filesystem.rawValue), \(drive.state.label)")
    }

    private var statusColor: Color { MountlyTheme.statusColor(for: drive.state) }

    private var sidebarStatusText: String {
        switch drive.state {
        case .mountedReadWrite, .mountedReadOnly: return "Mounted"
        default: return drive.state.label
        }
    }
}
