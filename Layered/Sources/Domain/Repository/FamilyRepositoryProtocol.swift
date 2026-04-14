import Foundation

protocol FamilyRepositoryProtocol {
    func createFamily(name: String, adminId: String) async throws -> Family
    func getFamily(id: String) async throws -> Family
    func deleteFamily(id: String) async throws
    func generateInviteCode(familyId: String) async throws -> String
    func joinFamily(inviteCode: String, userId: String) async throws -> Family
}
