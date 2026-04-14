import Foundation

protocol MemberRepositoryProtocol {
    func getMembers(familyId: String) async throws -> [Member]
    func getMember(familyId: String, memberId: String) async throws -> Member
    func removeMember(familyId: String, memberId: String) async throws
    func updateRotationOrder(familyId: String, memberOrders: [(memberId: String, order: Int)]) async throws
}
