import Foundation

struct Poll: Identifiable, Codable {
    let id: String
    var question: String
    var isAnonymous: Bool
    var allowMultiple: Bool
    var deadline: Date
    var status: Status
    var options: [PollOption]
    let createdAt: Date

    enum Status: String, Codable {
        case open
        case closed
    }
}

struct PollOption: Identifiable, Codable {
    let id: String
    var title: String
    var description: String?
    var imageURL: String?
    var voterIds: [String]
    var voteCount: Int
}
