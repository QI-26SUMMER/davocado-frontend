import SwiftUI

struct ScanHistoryRow: View {
    let scan: ScanListItem

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private var stage: RipenessStage? { RipenessStage(rawValue: scan.predictedStage) }
    private var stageColor: Color { stage?.color ?? .avocadoGreen }

    private var isNotified: Bool { scan.notification.status == "sent" }
    private var hasNotification: Bool { scan.notification.status != "none" }

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 9)
                .fill(stageColor)
                .frame(width: 40, height: 40)
                .overlay(
                    Text("\(scan.predictedStage)")
                        .font(.avocadoDisplay(16))
                        .foregroundStyle(.white)
                )

            VStack(alignment: .leading, spacing: 2) {
                // `stage_label` isn't sent by the server on purpose — derived from
                // `predictedStage` client-side (see ScanAPI.swift).
                Text(stage?.label ?? "Unknown")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.avocadoDarkText)
                Text(Self.dateFormatter.string(from: scan.createdAt))
                    .font(.system(size: 10))
                    .foregroundStyle(Color.avocadoTextBrown)
                DayBadge(display: scan.display)
                    .padding(.top, 4)
            }

            Spacer()

            // Display-only: the backend has no endpoint yet to toggle this per-scan.
            VStack(spacing: 6) {
                Image(systemName: hasNotification ? "bell.fill" : "bell.slash.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(isNotified ? Color.avocadoGreen : Color.avocadoTextBrown)
                Circle()
                    .fill(isNotified ? Color.avocadoGreen : Color.avocadoTextBrown)
                    .frame(width: 6, height: 6)
            }
        }
        .padding(17.7)
        .background(Color.avocadoCard, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.avocadoBorder, lineWidth: 1.7))
    }
}
