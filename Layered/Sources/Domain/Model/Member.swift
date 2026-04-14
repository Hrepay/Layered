import Foundation

struct Member: Identifiable, Codable {
    let id: String
    var name: String
    var profileImageURL: String?
    var role: Role
    var rotationOrder: Int
    let joinedAt: Date

    enum Role: String, Codable {
        case admin
        case member
    }
}
