import Foundation
import os

/// Structured logging via the unified logging system. Categories map
/// 1:1 to the subsystems named in the project brief. Never log file
/// contents, credentials, or other sensitive personal data — only
/// operational events (what happened, not what's inside the files).
public enum LogCategory: String {
    case driveDetection = "DriveDetection"
    case mountManager = "MountManager"
    case filesystemBackend = "FilesystemBackend"
    case transferManager = "TransferManager"
    case ejectManager = "EjectManager"
    case security = "Security"
    case ui = "UI"
}

public enum TMLog {
    public static let subsystem = "com.mountly.app"

    private static var loggers: [LogCategory: Logger] = [:]

    private static func logger(for category: LogCategory) -> Logger {
        if let existing = loggers[category] { return existing }
        let l = Logger(subsystem: subsystem, category: category.rawValue)
        loggers[category] = l
        return l
    }

    public static func info(_ message: String, category: LogCategory) {
        logger(for: category).info("\(message, privacy: .public)")
    }

    public static func notice(_ message: String, category: LogCategory) {
        logger(for: category).notice("\(message, privacy: .public)")
    }

    public static func error(_ message: String, category: LogCategory) {
        logger(for: category).error("\(message, privacy: .public)")
    }

    public static func fault(_ message: String, category: LogCategory) {
        logger(for: category).fault("\(message, privacy: .public)")
    }
}

/// A single recent event, kept in-memory for the Diagnostics screen.
public struct TMEvent: Identifiable, Sendable {
    public let id = UUID()
    public let date: Date
    public let category: String
    public let message: String

    public init(date: Date = Date(), category: String, message: String) {
        self.date = date
        self.category = category
        self.message = message
    }
}

/// Bounded in-memory ring buffer of recent events for Diagnostics. Not a
/// substitute for the unified log — just a convenient recent-history view.
@MainActor
public final class EventLog: ObservableObject {
    public static let shared = EventLog()

    @Published public private(set) var events: [TMEvent] = []
    private let maxEvents = 200

    public func record(_ message: String, category: LogCategory) {
        events.append(TMEvent(category: category.rawValue, message: message))
        if events.count > maxEvents {
            events.removeFirst(events.count - maxEvents)
        }
        switch category {
        case .security:
            TMLog.notice(message, category: category)
        default:
            TMLog.info(message, category: category)
        }
    }

    public func copyableText() -> String {
        events.map { "[\($0.date.formatted(.iso8601))] \($0.category): \($0.message)" }
            .joined(separator: "\n")
    }
}
