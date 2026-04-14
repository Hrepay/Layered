import Foundation

struct Meeting: Identifiable, Codable, Hashable {
    let id: String
    var plannerId: String
    var plannerName: String
    var meetingDate: Date
    var place: String
    var placeLatitude: Double?
    var placeLongitude: Double?
    var activity: String?
    var status: Status
    var hasPoll: Bool
    let createdAt: Date
    var updatedAt: Date

    enum Status: String, Codable {
        case planning
        case confirmed
        case completed
        case cancelled
    }
}
