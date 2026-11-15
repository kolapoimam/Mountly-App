import SwiftUI
import MountlyCore

/// Mountly's semantic color and iconography system. Color always
/// communicates *state*, never decoration: green means verified read/write,
/// blue means "connected, working on it," orange means a caveat worth
/// reading, red means don't proceed, purple marks advanced/diagnostic
/// surfaces. Filesystem badges get their own distinct, muted tint so
/// multiple drives of different types are easy to tell apart at a glance.
enum MountlyTheme {
    // MARK: - Drive state -> color

    static func statusColor(for state: DriveState) -> Color {
        switch state {
        case .mountedReadWrite:
            return .mtGreen
        case .detected, .detecting, .preparing, .mounting, .unmounting, .ejecting:
            return .mtBlue
        case .mountedReadOnly:
            return .mtOrange
        case .error, .unsafeToMount, .dirtyFilesystem, .windowsHibernationDetected:
            return .mtRed
        case .unsupportedFilesystem, .notConnected:
            return .secondary
        }
    }

    static func statusSystemImage(for state: DriveState) -> String {
        switch state {
        case .mountedReadWrite: return "checkmark.circle.fill"
        case .mountedReadOnly: return "lock.circle.fill"
        case .detected: return "circle.dotted"
        case .detecting, .preparing, .mounting, .unmounting, .ejecting: return "arrow.triangle.2.circlepath.circle.fill"
        case .error: return "xmark.octagon.fill"
        case .unsafeToMount, .dirtyFilesystem, .windowsHibernationDetected: return "exclamationmark.triangle.fill"
        case .unsupportedFilesystem: return "questionmark.circle.fill"
        case .notConnected: return "circle"
        }
    }

    // MARK: - Filesystem -> badge color / icon

    static func filesystemColor(for kind: FilesystemKind) -> Color {
        switch kind {
        case .ntfs: return .mtBlue
        case .exfat: return .mtTeal
        case .fat32: return .mtBrown
        case .apfs: return .mtPurple
        case .hfsPlus: return .mtIndigo
        case .ext4: return .mtOrange
        case .unknown: return .secondary
        }
    }

    static let driveSystemImage = "externaldrive.fill"

    static func connectionSystemImage(for type: ConnectionType) -> String {
        switch type {
        case .usb: return "cable.connector"
        case .thunderbolt: return "bolt.fill"
        case .sata: return "internaldrive"
        case .unknown: return "questionmark.circle"
        }
    }

    /// Purple marks "advanced" surfaces — Diagnostics.
    static let advancedTint: Color = .mtPurple
}

extension Color {
    static let mtGreen = Color(red: 0.20, green: 0.74, blue: 0.42)
    static let mtBlue = Color(red: 0.13, green: 0.51, blue: 0.96)
    static let mtOrange = Color(red: 0.95, green: 0.61, blue: 0.15)
    static let mtRed = Color(red: 0.92, green: 0.30, blue: 0.30)
    static let mtPurple = Color(red: 0.56, green: 0.38, blue: 0.92)
    static let mtTeal = Color(red: 0.16, green: 0.66, blue: 0.62)
    static let mtIndigo = Color(red: 0.38, green: 0.40, blue: 0.87)
    static let mtBrown = Color(red: 0.62, green: 0.48, blue: 0.36)
}

// Mirrors the same names on `ShapeStyle` so `.mtGreen`-style dot-shorthand
// works in `.foregroundStyle(...)` and other ShapeStyle-typed contexts, not
// just where a literal `Color` is expected.
extension ShapeStyle where Self == Color {
    static var mtGreen: Color { .mtGreen }
    static var mtBlue: Color { .mtBlue }
    static var mtOrange: Color { .mtOrange }
    static var mtRed: Color { .mtRed }
    static var mtPurple: Color { .mtPurple }
    static var mtTeal: Color { .mtTeal }
    static var mtIndigo: Color { .mtIndigo }
    static var mtBrown: Color { .mtBrown }
}
