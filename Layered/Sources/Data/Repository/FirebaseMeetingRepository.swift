import Foundation
import FirebaseFirestore
import FirebaseStorage

final class FirebaseMeetingRepository: MeetingRepositoryProtocol {
    private let db = Firestore.firestore()
    private let storage = Storage.storage()

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
        let meetingRef = meetingsRef(familyId: familyId).document(meetingId)

        // 1. polls 서브컬렉션 전부 삭제
        let pollsSnapshot = try await meetingRef.collection("polls").getDocuments()
        for pollDoc in pollsSnapshot.documents {
            try? await pollDoc.reference.delete()
        }

        // 2. records 서브컬렉션 — 사진 URL까지 전부 Storage에서 삭제 후 문서 삭제
        let recordsSnapshot = try await meetingRef.collection("records").getDocuments()
        for recordDoc in recordsSnapshot.documents {
            if let photos = recordDoc.data()["photos"] as? [String] {
                for urlString in photos {
                    try? await deletePhotoByURL(urlString)
                }
            }
            try? await recordDoc.reference.delete()
        }

        // 3. meeting 문서 자체 삭제
        try await meetingRef.delete()
    }

    /// Firebase Storage 다운로드 URL로부터 참조를 구성해 삭제.
    /// Mock asset:// 이나 picsum 같은 외부 URL은 무시.
    private func deletePhotoByURL(_ urlString: String) async throws {
        guard urlString.contains("firebasestorage") else { return }
        let ref = storage.reference(forURL: urlString)
        try await ref.delete()
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
