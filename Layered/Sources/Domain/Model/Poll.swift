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
    /// 장소 검색으로 고른 후보의 카카오 장소 ID·좌표.
    /// 후보 확정 시 Meeting에 그대로 복사돼 상세 지도 핀이 유지된다.
    var placeId: String? = nil
    var latitude: Double? = nil
    var longitude: Double? = nil
    var voterIds: [String]
    var voteCount: Int
}
