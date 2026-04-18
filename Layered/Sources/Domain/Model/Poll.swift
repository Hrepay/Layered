import Foundation

struct Poll: Identifiable, Codable {
    let id: String
    var question: String
    var isAnonymous: Bool
    var allowMultiple: Bool
    var options: [PollOption]
    let createdAt: Date
}

struct PollOption: Identifiable, Codable {
    let id: String
    var title: String
    var description: String?
    var imageURL: String?
    var linkURL: String?
    var voterIds: [String]
    var voteCount: Int
}
