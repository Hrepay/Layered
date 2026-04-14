import Foundation

final class MockFamilyRepository: FamilyRepositoryProtocol {
    func createFamily(name: String, adminId: String) async throws -> Family {
        MockData.family
    }

    func getFamily(id: String) async throws -> Family {
        MockData.family
    }

    func deleteFamily(id: String) async throws {}

    func generateInviteCode(familyId: String) async throws -> String {
        "ABC123"
    }

    func joinFamily(inviteCode: String, userId: String) async throws -> Family {
        MockData.family
    }
}
