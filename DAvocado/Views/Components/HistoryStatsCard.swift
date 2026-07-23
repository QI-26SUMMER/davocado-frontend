import SwiftUI

struct HistoryStatsCard: View {
    let total: Int
    let notified: Int
    let pending: Int

    var body: some View {
        HStack(spacing: 0) {
            stat(value: total, label: "Total Scans")
            divider
            stat(value: notified, label: "Notified")
            divider
            stat(value: pending, label: "Pending")
        }
        .padding(.vertical, 12)
        .background(Color.avocadoGreen, in: RoundedRectangle(cornerRadius: 12))
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.avocadoCream.opacity(0.15))
            .frame(width: 1)
            .padding(.vertical, 12)
    }

    private func stat(value: Int, label: String) -> some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.avocadoDisplay(24))
                .foregroundStyle(Color.avocadoCream)
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(Color.avocadoCream.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    HistoryStatsCard(total: 5, notified: 3, pending: 2)
        .padding()
        .background(Color.avocadoCream)
}
