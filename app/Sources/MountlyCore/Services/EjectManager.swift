import Foundation

/// Safe eject. Never ejects out from under an in-flight transfer by
/// default — the caller must either wait or explicitly cancel first.
@MainActor
public final class EjectManager: ObservableObject {
    public static let shared = EjectManager(registry: .default)

    private let registry: BackendRegistry
    private let transferManager: TransferManager

    public enum EjectOutcome: Sendable {
        case ejected
        case blockedByActiveTransfers(count: Int)
        case failed(TMError)
    }

    public init(registry: BackendRegistry, transferManager: TransferManager? = nil) {
        self.registry = registry
        self.transferManager = transferManager ?? .shared
    }

    public func eject(bsdName: String, store: DriveStore, force: Bool = false) async -> EjectOutcome {
        guard let drive = store.drive(bsdName: bsdName) else {
            return .failed(.diskNotFound(bsdName: bsdName))
        }

        guard let mountPoint = drive.mountPoint else {
            return .ejected
        }

        if !force {
            let activeCount = transferManager.activeJobCount(under: mountPoint)
            if activeCount > 0 {
                return .blockedByActiveTransfers(count: activeCount)
            }
        } else {
            transferManager.cancelAll(under: mountPoint)
        }

        guard let backend = registry.backend(for: drive.filesystem) else {
            let error = TMError.unmountFailed(technicalDetail: "no backend registered for \(drive.filesystem.rawValue)")
            store.updateState(bsdName: bsdName, to: .error(error))
            return .failed(error)
        }

        store.updateState(bsdName: bsdName, to: .unmounting)
        store.updateState(bsdName: bsdName, to: .ejecting)

        do {
            try await backend.unmount(mountPoint: mountPoint)
            store.clearMount(bsdName: bsdName)
            await EventLog.shared.record("Ejected \(bsdName)", category: .ejectManager)
            return .ejected
        } catch let error as TMError {
            store.updateState(bsdName: bsdName, to: .error(error))
            return .failed(error)
        } catch {
            let mapped = TMError.unmountFailed(technicalDetail: String(describing: error))
            store.updateState(bsdName: bsdName, to: .error(mapped))
            return .failed(mapped)
        }
    }
}
