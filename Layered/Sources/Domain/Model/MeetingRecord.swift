import Foundation

struct MeetingRecord: Identifiable, Codable {
    let id: String
    var memberId: String
    var memberName: String
    var photos: [String]
    var comment: String
    var rating: Int
    let createdAt: Date
    var updatedAt: Date
}
