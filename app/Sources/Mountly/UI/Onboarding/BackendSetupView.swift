import SwiftUI
import AppKit
import MountlyCore

/// The "One more step" dependency-installation flow.
/// Downloads and checksum-verifies the pinned macFUSE release, hands the
/// enclosed `.pkg` to the system's own installer UI (so Apple's own
/// authorization dialog handles admin approval — Mountly never
/// asks for a password itself), then installs NTFS-3G via Homebrew if
/// available.
struct BackendSetupView: View {
    @Binding var isPresented: Bool

    private enum Step {
        case intro, workingMacFUSE, awaitingMacFUSEInstaller, workingNTFS3G, done, failed
    }

    @State private var step: Step = .intro
    @State private var errorMessage: String?
    @State private var errorTechnicalDetail: String?
    @State private var macFUSEInstalled = false
    @State private var ntfs3gInstalled = false
    @State private var homebrewAvailable = false

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("One more step")
                .font(.mtTitle2)
            Text("Mountly needs an open-source NTFS component installed to provide write access. Nothing about your existing NTFS drive is touched by this step — only two small, well-known, actively maintained tools are installed.")
                .font(.mtCallout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            componentRow(
                title: "macFUSE \(BackendInstaller.macFUSEPin.version)",
                installed: macFUSEInstalled,
                detail: "Lets macOS run filesystem drivers in user space, with no kernel extension. You'll approve a system extension once, in Privacy & Security — that's Apple's own approval step."
            )
            componentRow(
                title: "NTFS-3G",
                installed: ntfs3gInstalled,
                detail: homebrewAvailable
                    ? "Installed via Homebrew (gromgit/fuse tap), already present on this Mac."
                    : "Requires Homebrew, the well-known open-source package manager — NTFS-3G has no standalone signed macOS installer, and needs macFUSE installed first."
            )

            if let errorMessage {
                VStack(alignment: .leading, spacing: 6) {
                    Text(errorMessage)
                        .font(.mtCallout)
                        .foregroundStyle(.red)
                        .fixedSize(horizontal: false, vertical: true)
                    if errorTechnicalDetail != nil {
                        Button("Copy Technical Details") { copyTechnicalDetail() }
                            .font(.mtCaption)
                            .buttonStyle(.plain)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            HStack {
                Button("Not Now") { isPresented = false }
                Spacer()
                if step == .workingMacFUSE || step == .workingNTFS3G {
                    ProgressView().controlSize(.small)
                }
                Button(actionTitle) { performNextAction() }
                    .buttonStyle(.borderedProminent)
                    .disabled(step == .workingMacFUSE || step == .workingNTFS3G)
            }
        }
        .padding(24)
        .frame(width: 480, height: 440)
        .task { await refreshStatus() }
    }

    private var actionTitle: String {
        switch step {
        case .intro: return "Set Up"
        case .workingMacFUSE, .workingNTFS3G: return "Working…"
        case .awaitingMacFUSEInstaller: return "I've Finished Installing macFUSE"
        case .done: return "Done"
        case .failed: return "Try Again"
        }
    }

    private func componentRow(title: String, installed: Bool, detail: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: installed ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(installed ? .green : .secondary)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.mtHeadline)
                Text(detail).font(.mtCaption).foregroundStyle(.secondary)
            }
        }
    }

    private func refreshStatus() async {
        macFUSEInstalled = await BackendInstaller.shared.isMacFUSEInstalled()
        ntfs3gInstalled = await BackendInstaller.shared.isNTFS3GInstalled()
        homebrewAvailable = await BackendInstaller.shared.homebrewPath() != nil
        if macFUSEInstalled && ntfs3gInstalled {
            step = .done
        }
    }

    private func performNextAction() {
        switch step {
        case .intro:
            if macFUSEInstalled {
                installNTFS3G()
            } else {
                downloadMacFUSE()
            }
        case .awaitingMacFUSEInstaller:
            Task {
                macFUSEInstalled = await BackendInstaller.shared.isMacFUSEInstalled()
                if macFUSEInstalled {
                    installNTFS3G()
                } else {
                    errorMessage = "macFUSE doesn't look installed yet. Finish the installer's steps (including approving the system extension in Privacy & Security), then try again."
                    errorTechnicalDetail = nil
                }
            }
        case .done:
            isPresented = false
        case .failed:
            step = .intro
            errorMessage = nil
        case .workingMacFUSE, .workingNTFS3G:
            break
        }
    }

    private func downloadMacFUSE() {
        step = .workingMacFUSE
        errorMessage = nil
        errorTechnicalDetail = nil
        Task {
            do {
                let dmgURL = try await BackendInstaller.shared.downloadAndVerifyMacFUSE { _ in }
                try openMacFUSEInstaller(from: dmgURL)
                step = .awaitingMacFUSEInstaller
            } catch {
                setError(from: error, context: "downloading macFUSE")
                step = .failed
            }
        }
    }

    /// Translates any error from the install flow into a clear, plain-
    /// language message with a concrete next step — never a raw
    /// `Error`/`String(describing:)` dump as the primary text. The full
    /// technical detail stays available via "Copy Technical Details" for
    /// anyone who wants it (or needs to report an issue).
    private func setError(from error: Error, context: String) {
        if let installerError = error as? BackendInstaller.InstallerError {
            switch installerError {
            case .checksumMismatch:
                errorMessage = "The downloaded macFUSE installer didn't match its expected checksum, so Mountly discarded it rather than risk installing something tampered with. Check your internet connection and try again."
            case .downloadFailed:
                errorMessage = "Mountly couldn't download macFUSE. Check your internet connection, then try again."
            case .noSystemInstallerFound:
                errorMessage = "Mountly couldn't find an installer inside the downloaded macFUSE disk image. Try again, or install macFUSE manually from its official site."
            case .homebrewRequired:
                errorMessage = "NTFS-3G needs Homebrew. Install Homebrew (see brew.sh) in Terminal, then reopen this screen."
            case .noPrebuiltPackageAvailable:
                errorMessage = "Homebrew doesn't have a ready-to-install NTFS-3G package for this Mac yet. Mountly won't compile software silently — see Troubleshooting for how to build it yourself via Homebrew, or try again after a Homebrew update."
            }
            errorTechnicalDetail = "\(context): \(installerError)"
        } else if let tmError = error as? TMError {
            errorMessage = "\(tmError.reason) \(tmError.recommendedAction)"
            errorTechnicalDetail = tmError.technicalDetail
        } else {
            errorMessage = "Something unexpected went wrong while \(context). Check your internet connection and try again."
            errorTechnicalDetail = "\(context): \(error)"
        }
    }

    private func copyTechnicalDetail() {
        guard let errorTechnicalDetail else { return }
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(errorTechnicalDetail, forType: .string)
    }

    private func openMacFUSEInstaller(from dmgURL: URL) throws {
        let attach = try ProcessRunner.run("/usr/bin/hdiutil", arguments: ["attach", dmgURL.path, "-nobrowse", "-plist"])
        guard attach.succeeded,
              let data = attach.standardOutput.data(using: .utf8),
              let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any],
              let entities = plist["system-entities"] as? [[String: Any]],
              let mountPoint = entities.compactMap({ $0["mount-point"] as? String }).first
        else {
            throw TMError.backendInstallFailed(technicalDetail: "hdiutil attach did not return a mount point")
        }
        guard let pkgName = try? FileManager.default.contentsOfDirectory(atPath: mountPoint).first(where: { $0.hasSuffix(".pkg") }) else {
            throw TMError.backendInstallFailed(technicalDetail: "no .pkg found inside the macFUSE disk image")
        }
        NSWorkspace.shared.open(URL(fileURLWithPath: mountPoint).appendingPathComponent(pkgName))
    }

    private func installNTFS3G() {
        step = .workingNTFS3G
        errorMessage = nil
        errorTechnicalDetail = nil
        Task {
            do {
                try await BackendInstaller.shared.installNTFS3G { _ in }
                await refreshStatus()
            } catch {
                setError(from: error, context: "installing NTFS-3G")
                step = .failed
            }
        }
    }
}
