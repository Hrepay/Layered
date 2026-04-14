import Foundation
import FirebaseFirestore

final class FirebaseRecordRepository: RecordRepositoryProtocol {
    private let db = Firestore.firestore()

    private func recordsRef(familyId: String, meetingId: String) -> CollectionReference {
        db.collection("families").document(familyId)
            .collection("meetings").document(meetingId)
            .collection("records")
    }

    func createRecord(familyId: String, meetingId: String, record: MeetingRecord) async throws -> MeetingRecord {
        let data: [String: Any] = [
            "memberId": record.memberId,
            "memberName": record.memberName,
            "photos": record.photos,
            "comment": record.comment,
            "rating": record.rating,
            "createdAt": Timestamp(date: Date()),
            "updatedAt": Timestamp(date: Date()),
        ]

        let docRef = recordsRef(familyId: familyId, meetingId: meetingId).document()
        try await docRef.setData(data)

        return MeetingRecord(
            id: docRef.documentID,
            memberId: record.memberId,
            memberName: record.memberName,
            photos: record.photos,
            comment: record.comment,
            rating: record.rating,
            createdAt: Date(),
            updatedAt: Date()
        )
    }

    func getRecords(familyId: String, meetingId: String) async throws -> [MeetingRecord] {
        let snapshot = try await recordsRef(familyId: familyId, meetingId: meetingId)
            .order(by: "createdAt")
            .getDocuments()

        return snapshot.documents.map { recordFromDoc($0) }
    }

    func updateRecord(familyId: String, meetingId: String, record: MeetingRecord) async throws {
        try await recordsRef(familyId: familyId, meetingId: meetingId).document(record.id).updateData([
            "photos": record.photos,
            "comment": record.comment,
            "rating": record.rating,
            "updatedAt": Timestamp(date: Date()),
        ])
    }

    func deleteRecord(familyId: String, meetingId: String, recordId: String) async throws {
        try await recordsRef(familyId: familyId, meetingId: meetingId).document(recordId).delete()
    }

    // MARK: - Helpers
    private func recordFromDoc(_ doc: QueryDocumentSnapshot) -> MeetingRecord {
        let data = doc.data()
        return MeetingRecord(
            id: doc.documentID,
            memberId: data["memberId"] as? String ?? "",
            memberName: data["memberName"] as? String ?? "",
            photos: data["photos"] as? [String] ?? [],
            comment: data["comment"] as? String ?? "",
            rating: data["rating"] as? Int ?? 0,
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
            updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date()
        )
    }
}
