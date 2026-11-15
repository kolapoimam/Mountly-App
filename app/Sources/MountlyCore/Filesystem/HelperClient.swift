import Foundation

/// App-side XPC client for `MountlyHelperTool`. This is the only type in
/// the app process that ever talks to the privileged helper; everything
/// else goes through `NTFSBackend`/`MountManager`.
public final class HelperClient: @unchecked Sendable {
    public static let shared = HelperClient()

    private let lock = NSLock()
    private var connection: NSXPCConnection?

    public enum HelperError: Error, Sendable {
        case connectionFailed
        case helperReturnedFailure(String)
        case notRegistered
    }

    private init() {}

    private func currentConnection() -> NSXPCConnection {
        lock.lock()
        defer { lock.unlock() }
        if let connection { return connection }

        let newConnection = NSXPCConnection(machServiceName: HelperXPC.machServiceName, options: .privileged)
        newConnection.remoteObjectInterface = NSXPCInterface(with: HelperXPCProtocol.self)
        newConnection.invalidationHandler = { [weak self] in
            guard let self else { return }
            self.lock.lock()
            self.connection = nil
            self.lock.unlock()
        }
        newConnection.interruptionHandler = { [weak self] in
            guard let self else { return }
            self.lock.lock()
            self.connection = nil
            self.lock.unlock()
        }
        newConnection.resume()
        connection = newConnection
        return newConnection
    }

    private func proxy(errorHandler: @escaping (Error) -> Void) -> HelperXPCProtocol? {
        currentConnection().remoteObjectProxyWithErrorHandler(errorHandler) as? HelperXPCProtocol
    }

    public func ping() async -> String? {
        await withCheckedContinuation { continuation in
            guard let proxy = proxy(errorHandler: { _ in continuation.resume(returning: nil) }) else {
                continuation.resume(returning: nil)
                return
            }
            proxy.ping { version in
                continuation.resume(returning: version)
            }
        }
    }

    public func mountNTFS(bsdName: String, mountPoint: String, readOnly: Bool) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            guard let proxy = proxy(errorHandler: { error in
                continuation.resume(throwing: HelperError.connectionFailed)
            }) else {
                continuation.resume(throwing: HelperError.notRegistered)
                return
            }
            proxy.mountNTFS(bsdName: bsdName, mountPoint: mountPoint, readOnly: readOnly) { success, message in
                if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: HelperError.helperReturnedFailure(message ?? "unknown error"))
                }
            }
        }
    }

    public func unmount(mountPoint: String) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            guard let proxy = proxy(errorHandler: { _ in
                continuation.resume(throwing: HelperError.connectionFailed)
            }) else {
                continuation.resume(throwing: HelperError.notRegistered)
                return
            }
            proxy.unmount(mountPoint: mountPoint) { success, message in
                if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: HelperError.helperReturnedFailure(message ?? "unknown error"))
                }
            }
        }
    }

    public func status(mountPoint: String) async -> Bool {
        await withCheckedContinuation { continuation in
            guard let proxy = proxy(errorHandler: { _ in continuation.resume(returning: false) }) else {
                continuation.resume(returning: false)
                return
            }
            proxy.status(mountPoint: mountPoint) { mounted, _ in
                continuation.resume(returning: mounted)
            }
        }
    }
}
