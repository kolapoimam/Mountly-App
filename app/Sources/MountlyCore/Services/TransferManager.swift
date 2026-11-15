import Foundation

/// Not actor-isolated on purpose: it's read from `copyFileWithProgress`,
/// which deliberately runs off the main actor for I/O throughput.
private let transferChunkSize = 4 * 1024 * 1024

/// Chunked, cancellable, progress-reporting file copy engine. Heavy
/// I/O runs off the main actor; only the small, frequent progress updates
/// hop onto it, so the UI stays responsive during multi-gigabyte copies.
@MainActor
public final class TransferManager: ObservableObject {
    public static let shared = TransferManager()

    @Published public private(set) var activeJobs: [TransferJob] = []
    private var tasks: [UUID: Task<Void, Never>] = [:]

    public typealias ConflictResolver = @Sendable (URL) async -> ConflictResolution

    public init() {}

    public func hasActiveTransfers(under mountPoint: URL) -> Bool {
        activeJobs.contains { job in
            Self.isActive(job.status) && job.files.contains {
                $0.sourceURL.path.hasPrefix(mountPoint.path) || $0.destinationURL.path.hasPrefix(mountPoint.path)
            }
        }
    }

    public func activeJobCount(under mountPoint: URL) -> Int {
        activeJobs.filter { job in
            Self.isActive(job.status) && job.files.contains {
                $0.sourceURL.path.hasPrefix(mountPoint.path) || $0.destinationURL.path.hasPrefix(mountPoint.path)
            }
        }.count
    }

    public static func isActive(_ status: TransferStatus) -> Bool {
        switch status {
        case .preparing, .transferring: return true
        default: return false
        }
    }

    @discardableResult
    public func startCopy(
        files: [TransferFileItem],
        direction: TransferDirection,
        conflictResolver: @escaping ConflictResolver
    ) -> TransferJob {
        let job = TransferJob(direction: direction, files: files)
        activeJobs.append(job)
        let task = Task {
            await Self.run(job: job, conflictResolver: conflictResolver)
        }
        tasks[job.id] = task
        return job
    }

    public func cancel(jobID: UUID) {
        tasks[jobID]?.cancel()
    }

    public func cancelAll(under mountPoint: URL) {
        for job in activeJobs where Self.isActive(job.status) {
            let touchesMount = job.files.contains {
                $0.sourceURL.path.hasPrefix(mountPoint.path) || $0.destinationURL.path.hasPrefix(mountPoint.path)
            }
            if touchesMount {
                tasks[job.id]?.cancel()
            }
        }
    }

    public func clearFinishedJobs() {
        activeJobs.removeAll { job in
            switch job.status {
            case .completed, .cancelled, .failed: return true
            default: return false
            }
        }
    }

    private static func run(job: TransferJob, conflictResolver: @escaping ConflictResolver) async {
        job.status = .transferring
        await EventLog.shared.record(
            "Starting \(job.direction.rawValue) transfer of \(job.totalFiles) file(s), \(job.totalBytes) bytes",
            category: .transferManager
        )

        for file in job.files {
            if Task.isCancelled {
                job.status = .cancelled
                await EventLog.shared.record("Transfer cancelled", category: .transferManager)
                return
            }

            job.currentFileName = file.sourceURL.lastPathComponent

            var destination = file.destinationURL
            if FileManager.default.fileExists(atPath: destination.path) {
                let resolution = await conflictResolver(destination)
                switch resolution {
                case .cancel:
                    job.status = .cancelled
                    return
                case .skip:
                    job.filesCompleted += 1
                    job.bytesTransferred += file.sizeBytes
                    continue
                case .replace:
                    break
                case .keepBoth:
                    destination = uniqueDestination(for: destination)
                }
            }

            do {
                try await copyFileWithProgress(from: file.sourceURL, to: destination, job: job)
            } catch is CancellationError {
                job.status = .cancelled
                return
            } catch let error as TMError {
                job.status = .failed(error)
                await EventLog.shared.record("Transfer failed: \(error)", category: .transferManager)
                return
            } catch {
                job.status = .failed(.sourceUnreadable(technicalDetail: String(describing: error)))
                return
            }

            job.filesCompleted += 1
        }

        job.status = .completed
        await EventLog.shared.record("Transfer completed: \(job.filesCompleted)/\(job.totalFiles) file(s)", category: .transferManager)
    }

    nonisolated private static func copyFileWithProgress(from source: URL, to destination: URL, job: TransferJob) async throws {
        let fm = FileManager.default
        try? fm.createDirectory(at: destination.deletingLastPathComponent(), withIntermediateDirectories: true)

        guard let input = FileHandle(forReadingAtPath: source.path) else {
            throw TMError.sourceUnreadable(technicalDetail: "could not open \(source.path)")
        }
        guard fm.createFile(atPath: destination.path, contents: nil),
              let output = FileHandle(forWritingAtPath: destination.path) else {
            try? input.close()
            throw TMError.mountFailed(technicalDetail: "could not create \(destination.path)")
        }

        defer {
            try? input.close()
            try? output.close()
        }

        while true {
            if Task.isCancelled {
                try? fm.removeItem(at: destination)
                throw CancellationError()
            }
            let chunk = input.readData(ofLength: transferChunkSize)
            if chunk.isEmpty { break }
            output.write(chunk)
            let count = Int64(chunk.count)
            await MainActor.run {
                job.bytesTransferred += count
                job.lastUpdate = Date()
            }
        }
    }

    nonisolated static func uniqueDestination(for url: URL) -> URL {
        let ext = url.pathExtension
        let base = ext.isEmpty ? url.lastPathComponent : String(url.lastPathComponent.dropLast(ext.count + 1))
        let dir = url.deletingLastPathComponent()
        var counter = 2
        var candidate = dir.appendingPathComponent(ext.isEmpty ? "\(base) copy" : "\(base) copy.\(ext)")
        while FileManager.default.fileExists(atPath: candidate.path) {
            candidate = dir.appendingPathComponent(ext.isEmpty ? "\(base) copy \(counter)" : "\(base) copy \(counter).\(ext)")
            counter += 1
        }
        return candidate
    }
}
