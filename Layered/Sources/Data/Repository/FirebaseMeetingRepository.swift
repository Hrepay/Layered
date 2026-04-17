import Foundation
import FirebaseFirestore

final class FirebaseMeetingRepository: MeetingRepositoryProtocol {
    private let db = Firestore.firestore()

    private func meetingsRef(familyId: String) -> CollectionReference {
        db.collection("families").document(familyId).collection("meetings")
    }

    func createMeeting(familyId: String, meeting: Meeting) async throws -> Meeting {
        let data: [String: Any] = [
            "plannerId": meeting.plannerId,
            "plannerName": meeting.plannerName,
            "meetingDate": Timestamp(date: meeting.meetingDate),
            "place": meeting.place,
            "placeLatitude": meeting.placeLatitude as Any,
            "placeLongitude": meeting.placeLongitude as Any,
            "placeURL": meeting.placeURL as Any,
            "activity": meeting.activity as Any,
            "status": meeting.status.rawValue,
            "hasPoll": meeting.hasPoll,
            "createdAt": Timestamp(date: Date()),
            "updatedAt": Timestamp(date: Date()),
        ]

        let docRef = meetingsRef(familyId: familyId).document()
        try await docRef.setData(data)

        return Meeting(
            id: docRef.documentID,
            plannerId: meeting.plannerId,
            plannerName: meeting.plannerName,
            meetingDate: meeting.meetingDate,
            place: meeting.place,
            placeLatitude: meeting.placeLatitude,
            placeLongitude: meeting.placeLongitude,
            placeURL: meeting.placeURL,
            activity: meeting.activity,
            status: meeting.status,
            hasPoll: meeting.hasPoll,
            createdAt: Date(),
            updatedAt: Date()
        )
    }

    func getMeetings(familyId: String) async throws -> [Meeting] {
        let snapshot = try await meetingsRef(familyId: familyId)
            .order(by: "meetingDate", descending: true)
            .getDocuments()

        return snapshot.documents.map { meetingFromDoc($0) }
    }

    func getMeeting(familyId: String, meetingId: String) async throws -> Meeting {
        let doc = try await meetingsRef(familyId: familyId).document(meetingId).getDocument()
        guard let data = doc.data() else {
            throw NSError(domain: "meeting", code: -1, userInfo: [NSLocalizedDescriptionKey: "모임을 찾을 수 없습니다"])
        }
        return meetingFromData(id: doc.documentID, data: data)
    }

    func updateMeeting(familyId: String, meeting: Meeting) async throws {
        try await meetingsRef(familyId: familyId).document(meeting.id).updateData([
            "meetingDate": Timestamp(date: meeting.meetingDate),
            "place": meeting.place,
            "placeLatitude": meeting.placeLatitude as Any,
            "placeLongitude": meeting.placeLongitude as Any,
            "placeURL": meeting.placeURL as Any,
            "activity": meeting.activity as Any,
            "status": meeting.status.rawValue,
            "hasPoll": meeting.hasPoll,
            "updatedAt": Timestamp(date: Date()),
        ])
    }

    func deleteMeeting(familyId: String, meetingId: String) async throws {
        try await meetingsRef(familyId: familyId).document(meetingId).delete()
    }

    // MARK: - Helpers
    private func meetingFromDoc(_ doc: QueryDocumentSnapshot) -> Meeting {
        meetingFromData(id: doc.documentID, data: doc.data())
    }

    private func meetingFromData(id: String, data: [String: Any]) -> Meeting {
        Meeting(
            id: id,
            plannerId: data["plannerId"] as? String ?? "",
            plannerName: data["plannerName"] as? String ?? "",
            meetingDate: (data["meetingDate"] as? Timestamp)?.dateValue() ?? Date(),
            place: data["place"] as? String ?? "",
            placeLatitude: data["placeLatitude"] as? Double,
            placeLongitude: data["placeLongitude"] as? Double,
            placeURL: data["placeURL"] as? String,
            activity: data["activity"] as? String,
            status: Meeting.Status(rawValue: data["status"] as? String ?? "planning") ?? .planning,
            hasPoll: data["hasPoll"] as? Bool ?? false,
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
            updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date()
        )
    }
}
