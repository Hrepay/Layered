import Foundation
import CoreLocation

/// 장소 검색 결과 1건. 카카오 로컬 등 어떤 제공자든 이 형태로 변환해 사용.
struct PlaceResult: Identifiable, Hashable {
    let id: String
    let name: String
    /// 표시용 카테고리 (예: "이탈리안", "카페")
    let category: String
    /// 도로명 주소 (없으면 지번 주소)
    let address: String
    /// 검색 중심으로부터의 거리(m). 중심 좌표 없이 검색하면 nil.
    let distanceMeters: Int?
    let phone: String?
    let latitude: Double
    let longitude: Double
    /// 상세 페이지 URL (카카오맵 place 페이지 등)
    let detailURL: String?

    var distanceText: String? {
        guard let distanceMeters else { return nil }
        if distanceMeters < 1000 { return "\(distanceMeters)m" }
        return String(format: "%.1fkm", Double(distanceMeters) / 1000)
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

/// 검색 카테고리 필터 칩.
enum PlaceSearchCategory: String, CaseIterable, Identifiable {
    case all = "전체"
    case korean = "한식"
    case chinese = "중식"
    case japanese = "일식"
    case western = "양식"
    case snack = "분식"
    case cafe = "카페"
    case pub = "술집"
    case attraction = "관광지"
    case lodging = "숙소"
    case culture = "문화시설"

    var id: String { rawValue }

    /// 음식점(FD6)/카페(CE7)가 아닌 자체 카카오 그룹 코드로 검색하는 여행 카테고리.
    /// '맛집' 키워드 합성·프랜차이즈 필터 같은 음식점 전용 로직을 타지 않는다.
    var isTravelCategory: Bool {
        switch self {
        case .attraction, .lodging, .culture: return true
        default: return false
        }
    }
}
