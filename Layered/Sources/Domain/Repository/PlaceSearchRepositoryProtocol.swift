import Foundation

protocol PlaceSearchRepositoryProtocol {
    /// 키워드·카테고리로 장소 검색.
    /// - Parameters:
    ///   - query: 검색어. 비어 있으면 카테고리 기반 검색 (좌표 필요).
    ///   - category: 필터 칩.
    ///   - restaurantsOnly: "맛집만 보기". 검색어에 '맛집'을 합성하고 인기도(정확도) 정렬로 전환.
    ///   - travelMode: 여행 검색. '전체' 칩이 음식점·카페에 더해 관광지·숙소·문화시설까지 포함.
    ///   - latitude/longitude: 검색 중심 좌표. 있으면 거리 표시 + (맛집만 OFF일 때) 거리순 정렬.
    func searchPlaces(
        query: String,
        category: PlaceSearchCategory,
        restaurantsOnly: Bool,
        travelMode: Bool,
        latitude: Double?,
        longitude: Double?
    ) async throws -> [PlaceResult]
}
