import Foundation
import Combine
import SwiftUI
import MountlyCore

/// Top-level app state, composing the Core services and a little bit of
/// app-only state (onboarding, backend-installed flag) that doesn't belong
/// in the reusable/testable Core library.
@MainActor
final class AppState: ObservableObject {
    let driveStore = DriveStore.shared
    let mountManager = MountManager.shared
    let ejectManager = EjectManager.shared
    let transferManager = TransferManager.shared
    let settings = SettingsStore.shared
    let eventLog = EventLog.shared

    @Published var hasCompletedOnboarding: Bool {
        didSet { UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding") }
    }
    @Published private(set) var backendInstalled = false
    @Published private(set) var helperRegistrationOutcome: HelperRegistrar.RegistrationOutcome?
    @Published private(set) var helperReachable = false
    @Published private(set) var macFUSEInstalled = false
    @Published private(set) var isRefreshing = false
    @Published var selectedDriveBSDName: String?

    /// Real, three-state summary for the toolbar's "Helper Active" pill —
    /// never a decorative always-green indicator.
    enum HelperStatus: Equatable {
        case active
        case needsApproval
        case inactive
    }

    var helperStatus: HelperStatus {
        if helperReachable { return .active }
        if helperRegistrationOutcome == .requiresApproval { return .needsApproval }
        return .inactive
    }

    private var didStart = false
    private var cancellables = Set<AnyCancellable>()
    private var autoVerifyAttempted = Set<String>()

    init() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }

    func start() {
        guard !didStart else { return }
        didStart = true
        driveStore.start()
        driveStore.$drives
            .sink { [weak self] drives in
                self?.autoVerifyNativelyWritableDrives(drives)
            }
            .store(in: &cancellables)
        Task {
            await NotificationService.shared.requestAuthorizationIfNeeded()
            await refresh()
        }
        // Register the privileged helper proactively at launch (best
        // effort) so its approval status is known before the user ever
        // clicks "Enable Write Access" — registration itself is idempotent
        // and safe to call every launch.
        let outcome = HelperRegistrar.registerIfNeeded()
        helperRegistrationOutcome = outcome
        Task { await EventLog.shared.record("Helper registration at launch: \(outcome)", category: .security) }
    }

    func openHelperApprovalSettings() {
        HelperRegistrar.openSystemSettingsLoginItems()
    }

    /// Re-checks every piece of live status this app surfaces: backend
    /// install state, macFUSE presence, helper registration/reachability,
    /// and re-verifies write access on any natively-supported drive that
    /// hasn't been checked yet. Backs the toolbar's refresh button — a
    /// real re-scan, not a cosmetic spinner.
    func refresh() async {
        isRefreshing = true
        defer { isRefreshing = false }
        async let installed = BackendInstaller.shared.isFullyInstalled()
        async let macfuse = BackendInstaller.shared.isMacFUSEInstalled()
        backendInstalled = await installed
        macFUSEInstalled = await macfuse
        helperRegistrationOutcome = HelperRegistrar.registerIfNeeded()
        helperReachable = await HelperClient.shared.ping() != nil
        autoVerifyAttempted.removeAll()
        autoVerifyNativelyWritableDrives(driveStore.drives)
    }

    /// exFAT/FAT32/APFS/HFS+ are already read/write via macOS's own native
    /// support — no backend install, no privileged helper, no user opt-in
    /// needed. This quietly verifies write access the moment such a drive
    /// is detected, so it shows "Read & Write" immediately rather than
    /// making the user click "Enable Write Access" for something the OS
    /// already handles. NTFS deliberately stays opt-in: it needs the
    /// backend installed and a privileged mount.
    private func autoVerifyNativelyWritableDrives(_ drives: [Drive]) {
        autoVerifyAttempted.formIntersection(Set(drives.map(\.bsdName)))
        for drive in drives where drive.state == .mountedReadOnly
            && drive.filesystem.isNativelySupported
            && drive.isEligibleForManagement {
            guard !autoVerifyAttempted.contains(drive.bsdName) else { continue }
            autoVerifyAttempted.insert(drive.bsdName)
            let bsdName = drive.bsdName
            Task { await mountManager.autoVerifyIfNativelyWritable(bsdName: bsdName, store: driveStore) }
        }
    }

    var selectedDrive: Drive? {
        guard let selectedDriveBSDName else { return driveStore.drives.first }
        return driveStore.drive(bsdName: selectedDriveBSDName) ?? driveStore.drives.first
    }
}
