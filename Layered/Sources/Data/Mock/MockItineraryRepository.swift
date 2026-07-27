import Foundation

final class MockItineraryRepository: ItineraryRepositoryProtocol {
    func getItems(familyId: String, meetingId: String) async throws -> [ItineraryItem] {
        meetingId == "meeting-trip" ? MockData.itineraryItems : []
    }

    func addItem(familyId: String, meetingId: String, item: ItineraryItem) async throws -> ItineraryItem {
        item
    }

    func updateItem(familyId: String, meetingId: String, item: ItineraryItem) async throws {}

    func deleteItem(familyId: String, meetingId: String, itemId: String) async throws {}

    func reorderItems(familyId: String, meetingId: String, items: [ItineraryItem]) async throws {}
}
