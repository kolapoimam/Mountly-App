import Foundation

/// Every error Mountly can surface. Each case carries exactly what
/// the UI layer needs to render Apple HIG-style "reason + recommended
/// action + copyable technical detail" error messaging —
/// never a raw process exit code as the headline.
public enum TMError: Error, Equatable, Sendable, Identifiable {
    case backendNotInstalled
    case backendInstallFailed(technicalDetail: String)
    case diskNotFound(bsdName: String)
    case unexpectedFilesystem(actual: FilesystemKind)
    case unsafeWindowsState
    case mountFailed(technicalDetail: String)
    case writeVerificationFailed(technicalDetail: String)
    case alreadyMounted
    case unmountFailed(technicalDetail: String)
    case transfersInProgress(count: Int)
    case fileAlreadyExists(name: String)
    case sourceUnreadable(technicalDetail: String)
    case destinationFull
    case driveDisconnectedDuringOperation
    case privilegedHelperUnavailable
    case helperApprovalRequired
    case internalDiskRefused
    case bootVolumeRefused

    public var id: String { String(describing: self) }

    /// The one-sentence, non-technical headline the user sees first.
    public var reason: String {
        switch self {
        case .backendNotInstalled:
            return "Mountly needs its NTFS component installed before it can enable write access."
        case .backendInstallFailed:
            return "Mountly couldn't finish installing the NTFS component."
        case .diskNotFound:
            return "That drive is no longer connected."
        case .unexpectedFilesystem(let actual):
            return "This volume is formatted as \(actual.rawValue), which isn't what Mountly expected here."
        case .unsafeWindowsState:
            return "Windows did not completely shut down this drive."
        case .mountFailed:
            return "Mountly couldn't enable write access."
        case .writeVerificationFailed:
            return "Mountly mounted the drive, but couldn't confirm it's actually writable."
        case .alreadyMounted:
            return "This drive is already mounted."
        case .unmountFailed:
            return "Mountly couldn't safely unmount this drive."
        case .transfersInProgress(let count):
            return count == 1
                ? "A file is still being written to this drive."
                : "\(count) files are still being written to this drive."
        case .fileAlreadyExists(let name):
            return "\"\(name)\" already exists at the destination."
        case .sourceUnreadable:
            return "Mountly couldn't read one of the source files."
        case .destinationFull:
            return "There isn't enough free space on the destination."
        case .driveDisconnectedDuringOperation:
            return "The drive was disconnected while Mountly was using it."
        case .privilegedHelperUnavailable:
            return "Mountly's helper isn't available right now."
        case .helperApprovalRequired:
            return "Mountly needs one-time approval to enable write access."
        case .internalDiskRefused:
            return "Mountly only manages external drives."
        case .bootVolumeRefused:
            return "Mountly will never mount or modify your startup disk."
        }
    }

    /// A plain-language explanation of *why*, for the expandable detail area.
    public var explanation: String {
        switch self {
        case .backendNotInstalled:
            return "Read/write NTFS support is provided by an open-source component (macFUSE + NTFS-3G) that isn't installed yet."
        case .backendInstallFailed:
            return "The macFUSE/NTFS-3G installer didn't finish successfully. Nothing about your drive has been changed."
        case .diskNotFound:
            return "It may have been unplugged, ejected from elsewhere, or lost power."
        case .unexpectedFilesystem:
            return "The filesystem changed or was misreported between detection and mounting. Nothing has been modified."
        case .unsafeWindowsState:
            return "The volume is flagged as hibernated or not cleanly shut down. Writing to it from macOS in this state could risk filesystem corruption, so Mountly will not attempt it."
        case .mountFailed:
            return "The NTFS driver wasn't able to complete the mount. This is often temporary — another app may still be using the drive, or the privileged helper needs a moment after a fresh install."
        case .writeVerificationFailed:
            return "A test file could not be created, read back, and removed successfully, so Mountly can't confirm this drive is actually writable."
        case .alreadyMounted:
            return "No action is needed — you can already use it."
        case .unmountFailed:
            return "Another process (Finder, Terminal, or an app) likely still has a file open on this drive."
        case .transfersInProgress:
            return "Ejecting now could corrupt the files currently being written."
        case .fileAlreadyExists:
            return "Choose whether to replace it, keep both copies, or skip it."
        case .sourceUnreadable:
            return "The file may have been moved, deleted, or locked since you selected it."
        case .destinationFull:
            return "Free up space on the drive, or choose fewer files to copy."
        case .driveDisconnectedDuringOperation:
            return "Any files that were mid-transfer may be incomplete. Reconnect the drive to check."
        case .privilegedHelperUnavailable:
            return "It may need to be reinstalled. Try relaunching Mountly."
        case .helperApprovalRequired:
            return "macOS requires you to approve Mountly's background helper in System Settings → General → Login Items & Extensions before it can mount drives. This is Apple's own one-time approval step, not something Mountly can skip."
        case .internalDiskRefused, .bootVolumeRefused:
            return "This is a built-in safety rule and cannot be overridden from the interface."
        }
    }

    /// Recommended next step shown as the primary call to action.
    public var recommendedAction: String {
        switch self {
        case .backendNotInstalled, .backendInstallFailed:
            return "Set up the NTFS component from the setup screen."
        case .diskNotFound, .driveDisconnectedDuringOperation:
            return "Reconnect the drive and try again."
        case .unexpectedFilesystem:
            return "Reconnect the drive and try again."
        case .unsafeWindowsState:
            return "Connect the drive to a Windows PC, fully shut it down (not sleep/fast startup), then reconnect it to your Mac."
        case .mountFailed, .privilegedHelperUnavailable:
            return "Try again. If this keeps happening, check Diagnostics."
        case .helperApprovalRequired:
            return "Open System Settings, allow Mountly's helper under Login Items & Extensions, then try again."
        case .writeVerificationFailed:
            return "The drive was returned to a safe, unmounted state. Try again, or mount read-only."
        case .alreadyMounted:
            return "Open it in Finder."
        case .unmountFailed:
            return "Close any apps or Finder windows using the drive, then try again."
        case .transfersInProgress:
            return "Wait for the transfer to finish, or cancel it first."
        case .fileAlreadyExists:
            return "Choose Replace, Keep Both, or Skip."
        case .sourceUnreadable:
            return "Check that the source file still exists and isn't locked."
        case .destinationFull:
            return "Free up space and try again."
        case .internalDiskRefused, .bootVolumeRefused:
            return "Choose an external drive instead."
        }
    }

    /// Everything above, formatted for the "Copy Technical Details" button.
    /// Deliberately just the case name plus its raw detail exactly once —
    /// an earlier version of this both truncated `String(describing: self)`
    /// to 64 characters *and* appended the same detail again in full,
    /// which produced a confusing, doubled-up string for any long
    /// underlying error (e.g. NTFS-3G's multi-line refusal messages).
    public var technicalDetail: String {
        switch self {
        case .backendInstallFailed(let d), .mountFailed(let d), .writeVerificationFailed(let d),
             .unmountFailed(let d), .sourceUnreadable(let d):
            return "\(caseName): \(d)"
        default:
            return String(describing: self)
        }
    }

    private var caseName: String {
        switch self {
        case .backendInstallFailed: return "backendInstallFailed"
        case .mountFailed: return "mountFailed"
        case .writeVerificationFailed: return "writeVerificationFailed"
        case .unmountFailed: return "unmountFailed"
        case .sourceUnreadable: return "sourceUnreadable"
        default: return String(describing: self)
        }
    }
}
