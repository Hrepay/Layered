import Foundation
import CoreLocation

/// 여행 일정표 항목 하나 — "n일차 m번째로 이곳에 간다".
/// `families/{fid}/meetings/{mid}/itinerary/{itemId}` 서브컬렉션에 저장.
struct ItineraryItem: Identifiable, Codable, Hashable {
    let id: String
    /// 1부터 시작하는 일차 (1일차, 2일차, …).
    var day: Int
    /// 같은 일차 안에서의 방문 순서 (0부터).
    var order: Int
    var name: String
    /// 장소 검색으로 고른 경우에만 채워지는 카카오 장소 정보.
    var placeId: String?
    var latitude: Double?
    var longitude: Double?
    var category: String?
    var detailURL: String?
    var memo: String?
    let createdAt: Date
    var updatedAt: Date

    var coordinate: CLLocationCoordinate2D? {
        guard let latitude, let longitude else { return nil }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

extension ItineraryItem {
    /// 장소 검색 결과로부터 새 일정 항목 생성.
    static func from(place: PlaceResult, day: Int, order: Int) -> ItineraryItem {
        ItineraryItem(
            id: UUID().uuidString,
            day: day,
            order: order,
            name: place.name,
            placeId: place.id,
            latitude: place.latitude,
            longitude: place.longitude,
            category: place.category,
            detailURL: place.detailURL,
            memo: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}
