import Foundation

/// The single place in the codebase that launches subprocesses. Deliberately
/// minimal and deliberately *not* shell-based: every call takes an
/// executable path and an argument array, never a string that gets handed
/// to `/bin/sh -c`. This is what makes "no silently executed privileged
/// commands" and "no shell injection" structurally true rather than just a
/// convention — there is nowhere in this codebase that builds a shell
/// command line from user/filesystem-derived strings.
public enum ProcessRunner {
    public struct Result: Sendable {
        public let exitCode: Int32
        public let standardOutput: String
        public let standardError: String

        public var succeeded: Bool { exitCode == 0 }
    }

    public enum RunnerError: Error, Sendable {
        case executableNotFound(String)
        case launchFailed(String)
    }

    /// Runs `executablePath` with `arguments`, waiting for completion.
    /// No `Process.launchPath` shell interpretation is ever used.
    @discardableResult
    public static func run(
        _ executablePath: String,
        arguments: [String],
        timeout: TimeInterval = 30
    ) throws -> Result {
        guard FileManager.default.isExecutableFile(atPath: executablePath) else {
            throw RunnerError.executableNotFound(executablePath)
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: executablePath)
        process.arguments = arguments

        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe

        do {
            try process.run()
        } catch {
            throw RunnerError.launchFailed(error.localizedDescription)
        }

        let deadline = Date().addingTimeInterval(timeout)
        while process.isRunning && Date() < deadline {
            Thread.sleep(forTimeInterval: 0.05)
        }
        if process.isRunning {
            process.terminate()
        }

        let outData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
        let errData = stderrPipe.fileHandleForReading.readDataToEndOfFile()

        return Result(
            exitCode: process.terminationStatus,
            standardOutput: String(data: outData, encoding: .utf8) ?? "",
            standardError: String(data: errData, encoding: .utf8) ?? ""
        )
    }
}
