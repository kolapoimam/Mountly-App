import SwiftUI

/// First-launch experience — deliberately a single short screen.
/// Backend setup (for NTFS specifically) is surfaced contextually later,
/// the moment a user actually tries to enable write access on an NTFS
/// drive and needs it — not front-loaded here, since most drives
/// (exFAT/FAT32/APFS/HFS+) need no setup step at all.
struct OnboardingView: View {
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.mtBlue.gradient)
                    .frame(width: 72, height: 72)
                Image(systemName: "externaldrive.connected.to.line.below")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundStyle(.white)
            }

            Text("Welcome to Mountly")
                .font(.mtTitle)
            Text("External drives, made accessible.")
                .font(.mtBody)
                .foregroundStyle(.secondary)
            Text("Mountly helps your Mac work with external filesystems safely and simply.")
                .font(.mtCallout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 10) {
                checklistRow("Detect drives automatically")
                checklistRow("Mount supported filesystems")
                checklistRow("Verify read/write access")
                checklistRow("Safely eject drives")
            }
            .padding(.top, 4)

            Spacer()

            Button("Get Started") { isPresented = false }
                .buttonStyle(.borderedProminent)
                .tint(.mtBlue)
                .controlSize(.large)
        }
        .padding(32)
        .frame(width: 440, height: 480)
    }

    private func checklistRow(_ text: String) -> some View {
        Label(text, systemImage: "checkmark.circle.fill")
            .foregroundStyle(.mtGreen)
            .font(.mtBody)
    }
}
