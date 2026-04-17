import Foundation

final class MockUserRepository: UserRepositoryProtocol {
    func getUser(id: String) async throws -> User {
        MockData.currentUser
    }

    func createUserIfNeeded(_ user: User) async throws {}

    func updateUser(_ user: User) async throws {}

    func loadNotificationSettings(userId: String) async throws -> NotificationSettings {
        NotificationSettings()
    }

    func updateNotificationSettings(userId: String, settings: NotificationSettings) async throws {}

    func recordTermsAgreement(userId: String, version: String, marketingConsent: Bool) async throws {}
}
