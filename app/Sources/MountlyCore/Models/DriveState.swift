import Foundation

/// Every state a drive can visibly be in. Deliberately exhaustive and never
/// collapsed in the UI — the whole point of this app is that the user
/// always knows exactly what is happening to their data.
public enum DriveState: Equatable, Sendable {
    case notConnected
    case detecting
    case detected
    case mountedReadOnly
    case preparing
    case mounting
    case mountedReadWrite
    case unmounting
    case ejecting
    case error(TMError)
    case unsupportedFilesystem(FilesystemKind)
    case unsafeToMount(reason: String)
    case dirtyFilesystem
    case windowsHibernationDetected

    public var isMounted: Bool {
        switch self {
        case .mountedReadWrite, .mountedReadOnly:
            return true
        default:
            return false
        }
    }

    public var isTransitional: Bool {
        switch self {
        case .detecting, .preparing, .mounting, .unmounting, .ejecting:
            return true
        default:
            return false
        }
    }

    /// Short, human-facing label. Longer explanations live in the UI layer
    /// so they can be laid out with recommended actions.
    public var label: String {
        switch self {
        case .notConnected: return "Not Connected"
        case .detecting: return "Detecting…"
        case .detected: return "Detected"
        case .mountedReadOnly: return "Read Only"
        case .preparing: return "Preparing…"
        case .mounting: return "Mounting…"
        case .mountedReadWrite: return "Read & Write"
        case .unmounting: return "Unmounting…"
        case .ejecting: return "Ejecting…"
        case .error: return "Error"
        case .unsupportedFilesystem(let kind): return "Unsupported (\(kind.rawValue))"
        case .unsafeToMount: return "Unsafe to Mount"
        case .dirtyFilesystem: return "Dirty Filesystem"
        case .windowsHibernationDetected: return "Windows Hibernation Detected"
        }
    }
}
