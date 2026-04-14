import Foundation

final class MockUserRepository: UserRepositoryProtocol {
    func getUser(id: String) async throws -> User {
        MockData.currentUser
    }

    func createUserIfNeeded(_ user: User) async throws {}

    func updateUser(_ user: User) async throws {}
}
