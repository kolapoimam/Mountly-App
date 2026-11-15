import SwiftUI

/// Menu command that opens the custom About window (needs `openWindow`,
/// which is only available from within a View's environment).
struct AboutMenuButton: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Button("About Mountly") {
            openWindow(id: "about")
        }
    }
}

/// Custom About window carrying the mandatory non-affiliation disclaimer.
struct AboutView: View {
    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "externaldrive.connected.to.line.below")
                .font(.system(size: 48))
                .foregroundStyle(.tint)
            Text("Mountly")
                .font(.mtTitle2)
            Text("Version \(AppVersion.marketingVersion)")
                .font(.mtCallout)
                .foregroundStyle(.secondary)
            Text("External drives, made accessible.")
                .font(.mtCallout)
                .foregroundStyle(.secondary)

            Divider().padding(.vertical, 4)

            Text("Mountly is an independent utility for working with external drives and is not affiliated with, endorsed by, or limited to any drive or storage device manufacturer.")
                .font(.mtCaption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 340)

            Text("NTFS read/write support is provided by the open-source macFUSE and NTFS-3G projects. See Third-Party Licenses in the app's documentation.")
                .font(.mtCaption2)
                .multilineTextAlignment(.center)
                .foregroundStyle(.tertiary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 340)
        }
        .padding(32)
        .frame(width: 400, height: 380)
    }
}
