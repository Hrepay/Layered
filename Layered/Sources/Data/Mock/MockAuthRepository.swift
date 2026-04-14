import Foundation

final class MockAuthRepository: AuthRepositoryProtocol {
    private var currentUser: User? = MockData.currentUser

    func signInWithApple() async throws -> User {
        currentUser = MockData.currentUser
        return MockData.currentUser
    }

    func signOut() throws {
        currentUser = nil
    }

    func deleteAccount() async throws {
        currentUser = nil
    }

    func getCurrentUser() -> User? {
        currentUser
    }
}
