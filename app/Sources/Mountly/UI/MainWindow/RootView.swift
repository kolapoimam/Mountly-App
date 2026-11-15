import SwiftUI
import MountlyCore

enum SidebarSection: String, CaseIterable, Identifiable {
    case drives = "Drives"
    case transfers = "Transfers"
    case diagnostics = "Diagnostics"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .drives: return "externaldrive"
        case .transfers: return "arrow.left.arrow.right"
        case .diagnostics: return "stethoscope"
        }
    }

    var tint: Color {
        switch self {
        case .drives: return .mtBlue
        case .transfers: return .mtGreen
        case .diagnostics: return .mtPurple
        }
    }
}

/// Root of the main window: a tabbed layout (Drives / Transfers /
/// Diagnostics) with a toolbar showing the privileged helper's real,
/// live status and a manual refresh action.
struct RootView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var driveStore: DriveStore
    @EnvironmentObject private var transferManager: TransferManager
    @State private var selectedTab: SidebarSection = .drives

    var body: some View {
        TabView(selection: $selectedTab) {
            DrivesSplitView()
                .tabItem { Label(SidebarSection.drives.rawValue, systemImage: SidebarSection.drives.systemImage) }
                .tag(SidebarSection.drives)
                .badge(driveCount)

            TransfersView()
                .tabItem { Label(SidebarSection.transfers.rawValue, systemImage: SidebarSection.transfers.systemImage) }
                .tag(SidebarSection.transfers)
                .badge(activeTransferCount)

            DiagnosticsView()
                .tabItem { Label(SidebarSection.diagnostics.rawValue, systemImage: SidebarSection.diagnostics.systemImage) }
                .tag(SidebarSection.diagnostics)
        }
        .toolbar {
            ToolbarItem(placement: .automatic) { helperStatusPill }
            ToolbarItem(placement: .automatic) { refreshButton }
        }
        .navigationTitle("Mountly")
        .sheet(isPresented: onboardingBinding) {
            OnboardingView(isPresented: onboardingBinding)
        }
    }

    private var driveCount: Int {
        driveStore.drives.filter { $0.isEligibleForManagement }.count
    }

    private var activeTransferCount: Int {
        transferManager.activeJobs.filter { TransferManager.isActive($0.status) }.count
    }

    private var onboardingBinding: Binding<Bool> {
        Binding(
            get: { !appState.hasCompletedOnboarding },
            set: { appState.hasCompletedOnboarding = !$0 }
        )
    }

    private var helperStatusPill: some View {
        let (color, text): (Color, String) = {
            switch appState.helperStatus {
            case .active: return (.mtGreen, "Helper Active")
            case .needsApproval: return (.mtOrange, "Needs Approval")
            case .inactive: return (.secondary, "Helper Inactive")
            }
        }()
        return HStack(spacing: 6) {
            Circle().fill(color).frame(width: 7, height: 7)
            Text(text).font(.mtCaption)
        }
        .foregroundStyle(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Capsule().fill(color.opacity(0.14)))
        .accessibilityElement(children: .combine)
    }

    private var refreshButton: some View {
        Button {
            Task { await appState.refresh() }
        } label: {
            if appState.isRefreshing {
                ProgressView().controlSize(.small)
            } else {
                Image(systemName: "arrow.clockwise")
            }
        }
        .accessibilityLabel("Refresh")
        .disabled(appState.isRefreshing)
    }
}

enum AppVersion {
    static let marketingVersion = "1.0.0"
}
