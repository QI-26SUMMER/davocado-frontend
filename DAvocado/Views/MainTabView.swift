import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            Tab("Scan", systemImage: "camera.fill") {
                NavigationStack {
                    ScanView()
                }
            }

            Tab("History", systemImage: "clock.fill") {
                NavigationStack {
                    HistoryView()
                }
            }

            Tab("Settings", systemImage: "gearshape.fill") {
                NavigationStack {
                    SettingsView()
                }
            }
        }
        .tint(Color.avocadoGreen)
    }
}

#Preview {
    MainTabView()
        .environment(AppState())
}
