import Foundation

struct Family: Identifiable, Codable {
    let id: String
    var name: String
    var inviteCode: String
    var inviteCodeExpiresAt: Date
    var adminId: String
    var memberCount: Int
    var currentPlannerIndex: Int
    var rotationDay: Int // 1=월...7=일
    var rotationMode: String // "auto" or "manual"
    let createdAt: Date
}
