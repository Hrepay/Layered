import Foundation

protocol ItineraryRepositoryProtocol {
    /// 일차·순서 정렬된 전체 일정표.
    func getItems(familyId: String, meetingId: String) async throws -> [ItineraryItem]
    func addItem(familyId: String, meetingId: String, item: ItineraryItem) async throws -> ItineraryItem
    func updateItem(familyId: String, meetingId: String, item: ItineraryItem) async throws
    func deleteItem(familyId: String, meetingId: String, itemId: String) async throws
    /// 순서 변경 등 여러 항목의 day/order 일괄 갱신 (batch).
    func reorderItems(familyId: String, meetingId: String, items: [ItineraryItem]) async throws
}
