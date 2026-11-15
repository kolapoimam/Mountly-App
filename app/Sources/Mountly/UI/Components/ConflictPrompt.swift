import AppKit
import MountlyCore

/// Presents the "File already exists" choice as a native modal
/// alert. Used as the `TransferManager.ConflictResolver` — the copy loop
/// genuinely waits for the user's decision before continuing, so a modal
/// alert (rather than routing through more SwiftUI state) is the simplest
/// correct implementation here.
enum ConflictPrompt {
    @MainActor
    static func resolve(destination: URL) async -> ConflictResolution {
        let alert = NSAlert()
        alert.messageText = "\"\(destination.lastPathComponent)\" already exists."
        alert.informativeText = "Choose whether to replace it, keep both copies, or skip it."
        alert.addButton(withTitle: "Replace")
        alert.addButton(withTitle: "Keep Both")
        alert.addButton(withTitle: "Skip")
        alert.addButton(withTitle: "Cancel")
        alert.alertStyle = .warning

        let response = alert.runModal()
        switch response {
        case .alertFirstButtonReturn: return .replace
        case .alertSecondButtonReturn: return .keepBoth
        case .alertThirdButtonReturn: return .skip
        default: return .cancel
        }
    }
}
