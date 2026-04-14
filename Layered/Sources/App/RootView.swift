import SwiftUI

struct RootView: View {
    @State private var appState = AppState()

    var body: some View {
        Group {
            switch appState.authState {
            case .splash:
                SplashView()
            case .onboarding:
                OnboardingView(onComplete: {
                    appState.completeOnboarding()
                })
            case .login:
                LoginView(onSignIn: {
                    Task {
                        await appState.signInWithApple()
                    }
                })
            case .familySetup:
                FamilySetupView(onJoined: { family in
                    appState.joinedFamily(family)
                })
                .environment(appState)
            case .home:
                MainTabView()
                    .environment(appState)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appState.authState)
        .loadingOverlay(appState.isLoading)
        .onAppear {
            appState.checkAuthState()
        }
    }
}
