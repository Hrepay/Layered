import Foundation

protocol MemberRepositoryProtocol {
    func getMembers(familyId: String) async throws -> [Member]
    func getMember(familyId: String, memberId: String) async throws -> Member
    func removeMember(familyId: String, memberId: String) async throws
    func updateRotationOrder(familyId: String, memberOrders: [(memberId: String, order: Int)]) async throws
    func syncMemberProfileImage(familyId: String, memberId: String, imageURL: String) async throws
    func updateMemberProfile(familyId: String, memberId: String, name: String, profileImageURL: String?) async throws
}
