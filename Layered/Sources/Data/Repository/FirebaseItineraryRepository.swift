import Foundation
import FirebaseFirestore

final class FirebaseItineraryRepository: ItineraryRepositoryProtocol {
    private let db = Firestore.firestore()

    private func itemsRef(familyId: String, meetingId: String) -> CollectionReference {
        db.collection("families").document(familyId)
            .collection("meetings").document(meetingId)
            .collection("itinerary")
    }

    func getItems(familyId: String, meetingId: String) async throws -> [ItineraryItem] {
        let snapshot = try await itemsRef(familyId: familyId, meetingId: meetingId).getDocuments()
        // 복합 인덱스 없이 클라이언트 정렬 — 일정표는 수십 건 규모라 부담 없음.
        return snapshot.documents
            .map { itemFromData(id: $0.documentID, data: $0.data()) }
            .sorted { ($0.day, $0.order) < ($1.day, $1.order) }
    }

    func addItem(familyId: String, meetingId: String, item: ItineraryItem) async throws -> ItineraryItem {
        let docRef = itemsRef(familyId: familyId, meetingId: meetingId).document()
        let now = Date()
        try await docRef.setData(itemData(item, createdAt: now, updatedAt: now))

        return ItineraryItem(
            id: docRef.documentID,
            day: item.day,
            order: item.order,
            name: item.name,
            placeId: item.placeId,
            latitude: item.latitude,
            longitude: item.longitude,
            category: item.category,
            detailURL: item.detailURL,
            memo: item.memo,
            createdAt: now,
            updatedAt: now
        )
    }

    func updateItem(familyId: String, meetingId: String, item: ItineraryItem) async throws {
        try await itemsRef(familyId: familyId, meetingId: meetingId)
            .document(item.id)
            .updateData([
                "day": item.day,
                "order": item.order,
                "name": item.name,
                "placeId": item.placeId as Any,
                "latitude": item.latitude as Any,
                "longitude": item.longitude as Any,
                "category": item.category as Any,
                "detailURL": item.detailURL as Any,
                "memo": item.memo as Any,
                "updatedAt": Timestamp(date: Date()),
            ])
    }

    func deleteItem(familyId: String, meetingId: String, itemId: String) async throws {
        try await itemsRef(familyId: familyId, meetingId: meetingId).document(itemId).delete()
    }

    func reorderItems(familyId: String, meetingId: String, items: [ItineraryItem]) async throws {
        let batch = db.batch()
        let ref = itemsRef(familyId: familyId, meetingId: meetingId)
        for item in items {
            batch.updateData([
                "day": item.day,
                "order": item.order,
                "updatedAt": Timestamp(date: Date()),
            ], forDocument: ref.document(item.id))
        }
        try await batch.commit()
    }

    // MARK: - Helpers

    private func itemData(_ item: ItineraryItem, createdAt: Date, updatedAt: Date) -> [String: Any] {
        [
            "day": item.day,
            "order": item.order,
            "name": item.name,
            "placeId": item.placeId as Any,
            "latitude": item.latitude as Any,
            "longitude": item.longitude as Any,
            "category": item.category as Any,
            "detailURL": item.detailURL as Any,
            "memo": item.memo as Any,
            "createdAt": Timestamp(date: createdAt),
            "updatedAt": Timestamp(date: updatedAt),
        ]
    }

    private func itemFromData(id: String, data: [String: Any]) -> ItineraryItem {
        ItineraryItem(
            id: id,
            day: data["day"] as? Int ?? 1,
            order: data["order"] as? Int ?? 0,
            name: data["name"] as? String ?? "",
            placeId: data["placeId"] as? String,
            latitude: data["latitude"] as? Double,
            longitude: data["longitude"] as? Double,
            category: data["category"] as? String,
            detailURL: data["detailURL"] as? String,
            memo: data["memo"] as? String,
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
            updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date()
        )
    }
}
