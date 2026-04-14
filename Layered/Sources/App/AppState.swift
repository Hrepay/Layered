import SwiftUI
import FirebaseAuth

enum AuthState: Equatable {
    case splash
    case onboarding
    case login
    case familySetup
    case home
}

@Observable
final class AppState {
    var authState: AuthState = .splash
    var currentUser: User?
    var currentFamily: Family?
    var isLoading = false
    var errorMessage: String?

    // @Observable은 lazy를 지원하지 않으므로 nonisolated(unsafe)로 선언
    nonisolated(unsafe) private var _authRepository: AuthRepositoryProtocol?
    nonisolated(unsafe) private var _userRepository: UserRepositoryProtocol?
    nonisolated(unsafe) private var _familyRepository: FamilyRepositoryProtocol?

    private var authRepository: AuthRepositoryProtocol {
        if _authRepository == nil { _authRepository = FirebaseAuthRepository() }
        return _authRepository!
    }
    private var userRepository: UserRepositoryProtocol {
        if _userRepository == nil { _userRepository = FirebaseUserRepository() }
        return _userRepository!
    }
    private var familyRepository: FamilyRepositoryProtocol {
        if _familyRepository == nil { _familyRepository = FirebaseFamilyRepository() }
        return _familyRepository!
    }

    private var hasSeenOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: "hasSeenOnboarding") }
        set { UserDefaults.standard.set(newValue, forKey: "hasSeenOnboarding") }
    }

    // MARK: - 스플래시 후 상태 결정
    func checkAuthState() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if let firebaseUser = Auth.auth().currentUser {
                Task { @MainActor in
                    await self.loadUserData(uid: firebaseUser.uid)
                }
            } else if self.hasSeenOnboarding {
                self.authState = .login
            } else {
                self.authState = .onboarding
            }
        }
    }

    // MARK: - 온보딩 완료
    func completeOnboarding() {
        hasSeenOnboarding = true
        authState = .login
    }

    // MARK: - Apple 로그인
    func signInWithApple() async {
        isLoading = true
        errorMessage = nil
        do {
            let user = try await authRepository.signInWithApple()
            try await userRepository.createUserIfNeeded(user)
            await loadUserData(uid: user.id)
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    // MARK: - 유저 데이터 로드 → 화면 분기
    @MainActor
    private func loadUserData(uid: String) async {
        isLoading = true
        do {
            let user = try await userRepository.getUser(id: uid)
            currentUser = user

            if let familyId = user.familyId {
                let family = try await familyRepository.getFamily(id: familyId)
                currentFamily = family
                authState = .home
            } else {
                authState = .familySetup
            }
        } catch {
            let newUser = User(
                id: uid,
                name: Auth.auth().currentUser?.displayName ?? "사용자",
                profileImageURL: nil,
                familyId: nil,
                createdAt: Date()
            )
            try? await userRepository.createUserIfNeeded(newUser)
            currentUser = newUser
            authState = .familySetup
        }
        isLoading = false
    }

    // MARK: - 가정 참여 완료
    func joinedFamily(_ family: Family) {
        currentFamily = family
        if let user = currentUser {
            Task {
                var updatedUser = user
                updatedUser.familyId = family.id
                try? await userRepository.updateUser(updatedUser)
            }
        }
        authState = .home
    }

    // MARK: - 로그아웃
    func signOut() {
        try? authRepository.signOut()
        currentUser = nil
        currentFamily = nil
        authState = .login
    }

    // MARK: - 계정 삭제
    func deleteAccount() async {
        isLoading = true
        do {
            try await authRepository.deleteAccount()
            currentUser = nil
            currentFamily = nil
            authState = .login
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
