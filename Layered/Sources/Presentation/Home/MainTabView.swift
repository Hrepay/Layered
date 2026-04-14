import SwiftUI

struct MainTabView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        Group {
            if let family = appState.currentFamily,
               let user = appState.currentUser {
                TabView {
                    HomeView(
                        family: family,
                        members: appState.members,
                        meetings: appState.meetings,
                        currentUser: user
                    )
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("홈")
                    }

                    HistoryView()
                        .environment(appState)
                        .tabItem {
                            Image(systemName: "clock.fill")
                            Text("히스토리")
                        }

                    SettingsView()
                        .environment(appState)
                        .tabItem {
                            Image(systemName: "gearshape.fill")
                            Text("설정")
                        }
                }
                .tint(AppColors.primary)
                .task {
                    await appState.loadHomeData()
                }
            }
        }
    }
}

#Preview {
    MainTabView()
        .environment(AppState())
}
