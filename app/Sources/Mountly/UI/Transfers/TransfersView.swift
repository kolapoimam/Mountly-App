import SwiftUI
import MountlyCore

/// Transfer progress UI.
struct TransfersView: View {
    @EnvironmentObject private var transferManager: TransferManager

    var body: some View {
        ScrollView {
            if transferManager.activeJobs.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "arrow.left.arrow.right.circle")
                        .font(.system(size: 44))
                        .foregroundStyle(.tertiary)
                    Text("No Transfers")
                        .font(.mtTitle3)
                    Text("Copy operations to or from a mounted drive will appear here.")
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 100)
                .frame(maxWidth: .infinity)
            } else {
                LazyVStack(spacing: 14) {
                    ForEach(transferManager.activeJobs) { job in
                        TransferRow(job: job)
                    }
                }
                .padding(24)
                .frame(maxWidth: 640)
            }
        }
        .frame(maxWidth: .infinity)
        .navigationTitle("Transfers")
        .toolbar {
            ToolbarItem {
                Button("Clear Finished") { transferManager.clearFinishedJobs() }
            }
        }
    }
}

private struct TransferRow: View {
    @ObservedObject var job: TransferJob
    @EnvironmentObject private var transferManager: TransferManager

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(job.direction.rawValue).font(.mtCaption).foregroundStyle(.secondary)
                Spacer()
                statusLabel
            }
            Text(job.currentFileName.isEmpty ? "Preparing…" : job.currentFileName)
                .font(.mtBodyMedium)
                .lineLimit(1)

            ProgressView(value: job.fractionComplete)

            HStack {
                Text("\(ByteCountFormatter.string(fromByteCount: job.bytesTransferred, countStyle: .file)) / \(ByteCountFormatter.string(fromByteCount: job.totalBytes, countStyle: .file))")
                Spacer()
                Text("\(Int(job.fractionComplete * 100))%")
            }
            .font(.mtCaption)
            .foregroundStyle(.secondary)

            HStack {
                Text(TransferJob.formattedSpeed(job.speedBytesPerSecond))
                Spacer()
                Text(TransferJob.formattedRemaining(job.estimatedSecondsRemaining))
            }
            .font(.mtCaption)
            .foregroundStyle(.secondary)

            if TransferManager.isActive(job.status) {
                HStack {
                    Spacer()
                    Button("Cancel") { transferManager.cancel(jobID: job.id) }
                        .controlSize(.small)
                }
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(.background.secondary))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(.separator))
    }

    @ViewBuilder
    private var statusLabel: some View {
        switch job.status {
        case .preparing: Text("Preparing").font(.mtCaption).foregroundStyle(.secondary)
        case .transferring: Text("Copying").font(.mtCaption).foregroundStyle(.blue)
        case .paused: Text("Paused").font(.mtCaption).foregroundStyle(.orange)
        case .completed: Text("Completed").font(.mtCaption).foregroundStyle(.green)
        case .cancelled: Text("Cancelled").font(.mtCaption).foregroundStyle(.secondary)
        case .failed(let error): Text("Failed: \(error.reason)").font(.mtCaption).foregroundStyle(.red)
        }
    }
}
