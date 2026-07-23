import SwiftUI

struct HistoryView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        ScrollView {
            ScreenHeader(title: "HISTORY", subtitle: "Your Scan History") {
                Image(systemName: "bell")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.avocadoGreen)
                    .padding(.top, 8)
            }

            HistoryStatsCard(
                total: appState.stats?.total ?? 0,
                notified: appState.stats?.notified ?? 0,
                pending: appState.stats?.pending ?? 0
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 16)

            if appState.scans.isEmpty && appState.isLoadingHistory {
                ProgressView()
                    .tint(Color.avocadoGreen)
                    .padding(.top, 40)
            } else if appState.scans.isEmpty {
                Text("No scans yet — take your first photo in the Scan tab.")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.avocadoTextBrown)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 40)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(appState.scans) { scan in
                        ScanHistoryRow(scan: scan)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
        }
        .background(Color.avocadoCream)
        .refreshable {
            async let history: Void = appState.loadHistory()
            async let stats: Void = appState.loadStats()
            _ = await (history, stats)
        }
        .task {
            if appState.scans.isEmpty {
                async let history: Void = appState.loadHistory()
                async let stats: Void = appState.loadStats()
                _ = await (history, stats)
            }
        }
    }
}

#Preview {
    NavigationStack {
        HistoryView()
    }
    .environment(AppState())
}
