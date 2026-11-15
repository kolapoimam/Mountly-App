import Foundation

public enum TransferDirection: String, Sendable {
    case macToDrive = "Mac → Drive"
    case driveToMac = "Drive → Mac"
}

public enum ConflictResolution: Sendable {
    case replace
    case keepBoth
    case skip
    case cancel
}

public enum TransferStatus: Equatable, Sendable {
    case preparing
    case transferring
    case paused
    case completed
    case cancelled
    case failed(TMError)
}

/// One file within a transfer job.
public struct TransferFileItem: Identifiable, Sendable {
    public let id = UUID()
    public let sourceURL: URL
    public let destinationURL: URL
    public let sizeBytes: Int64

    public init(sourceURL: URL, destinationURL: URL, sizeBytes: Int64) {
        self.sourceURL = sourceURL
        self.destinationURL = destinationURL
        self.sizeBytes = sizeBytes
    }
}

/// Observable progress state for a single copy operation. Owned and
/// mutated only by `TransferManager`; the UI observes it read-only.
@MainActor
public final class TransferJob: ObservableObject, Identifiable {
    public let id = UUID()
    public let direction: TransferDirection
    public let files: [TransferFileItem]
    public let totalBytes: Int64
    public let startDate: Date

    @Published public var status: TransferStatus = .preparing
    @Published public var currentFileName: String = ""
    @Published public var filesCompleted: Int = 0
    @Published public var bytesTransferred: Int64 = 0
    @Published public var lastUpdate: Date = Date()

    public init(direction: TransferDirection, files: [TransferFileItem]) {
        self.direction = direction
        self.files = files
        self.totalBytes = files.reduce(0) { $0 + $1.sizeBytes }
        self.startDate = Date()
    }

    public var totalFiles: Int { files.count }

    public var fractionComplete: Double {
        totalBytes == 0 ? 0 : Double(bytesTransferred) / Double(totalBytes)
    }

    /// Bytes/sec averaged over the whole job so far — stable enough for a
    /// UI label without jittering on every chunk.
    public var speedBytesPerSecond: Double {
        let elapsed = Date().timeIntervalSince(startDate)
        guard elapsed > 0.25 else { return 0 }
        return Double(bytesTransferred) / elapsed
    }

    public var estimatedSecondsRemaining: Double? {
        let speed = speedBytesPerSecond
        guard speed > 0 else { return nil }
        let remainingBytes = totalBytes - bytesTransferred
        guard remainingBytes > 0 else { return 0 }
        return Double(remainingBytes) / speed
    }
}

public extension TransferJob {
    static func formattedSpeed(_ bytesPerSecond: Double) -> String {
        guard bytesPerSecond > 0 else { return "—" }
        return ByteCountFormatter.string(fromByteCount: Int64(bytesPerSecond), countStyle: .file) + "/s"
    }

    static func formattedRemaining(_ seconds: Double?) -> String {
        guard let seconds, seconds.isFinite, seconds > 0 else { return "—" }
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = seconds >= 3600 ? [.hour, .minute] : [.minute, .second]
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 2
        return (formatter.string(from: seconds) ?? "—") + " remaining"
    }
}
