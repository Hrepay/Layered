import Foundation

protocol AuthRepositoryProtocol {
    func signInWithApple() async throws -> User
    func signOut() throws
    func deleteAccount() async throws
    func getCurrentUser() -> User?
}
