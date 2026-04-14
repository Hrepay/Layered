import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("홈")
                }

            HistoryView()
                .tabItem {
                    Image(systemName: "clock.fill")
                    Text("히스토리")
                }

            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("설정")
                }
        }
        .tint(AppColors.primary)
    }
}

#Preview {
    MainTabView()
}
