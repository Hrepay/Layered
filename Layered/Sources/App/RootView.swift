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
                LoginView(onSignIn: { marketingConsent in
                    Task {
                        await appState.signInWithApple(marketingConsent: marketingConsent)
                    }
                }, onDebugSignIn: { email, password, marketingConsent in
                    Task {
                        await appState.signInWithEmail(email: email, password: password, marketingConsent: marketingConsent)
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
        .loadingOverlay(appState.isLoading && appState.authState != .splash)
        .errorAlert(Bindable(appState).error)
        .onAppear {
            appState.checkAuthState()
        }
    }
}
