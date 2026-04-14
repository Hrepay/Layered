import Foundation
import FirebaseFirestore

final class FirebaseMemberRepository: MemberRepositoryProtocol {
    private let db = Firestore.firestore()

    private func membersRef(familyId: String) -> CollectionReference {
        db.collection("families").document(familyId).collection("members")
    }

    func getMembers(familyId: String) async throws -> [Member] {
        let snapshot = try await membersRef(familyId: familyId)
            .order(by: "rotationOrder")
            .getDocuments()

        return snapshot.documents.map { memberFromDoc($0) }
    }

    func getMember(familyId: String, memberId: String) async throws -> Member {
        let doc = try await membersRef(familyId: familyId).document(memberId).getDocument()
        guard let data = doc.data() else {
            throw NSError(domain: "member", code: -1, userInfo: [NSLocalizedDescriptionKey: "구성원을 찾을 수 없습니다"])
        }
        return memberFromData(id: doc.documentID, data: data)
    }

    func removeMember(familyId: String, memberId: String) async throws {
        try await membersRef(familyId: familyId).document(memberId).delete()

        // memberCount 감소
        try await db.collection("families").document(familyId).updateData([
            "memberCount": FieldValue.increment(Int64(-1))
        ])

        // User의 familyId 제거
        try await db.collection("users").document(memberId).updateData([
            "familyId": FieldValue.delete()
        ])
    }

    func updateRotationOrder(familyId: String, memberOrders: [(memberId: String, order: Int)]) async throws {
        let batch = db.batch()
        for item in memberOrders {
            let ref = membersRef(familyId: familyId).document(item.memberId)
            batch.updateData(["rotationOrder": item.order], forDocument: ref)
        }
        try await batch.commit()
    }

    // MARK: - Helpers
    private func memberFromDoc(_ doc: QueryDocumentSnapshot) -> Member {
        memberFromData(id: doc.documentID, data: doc.data())
    }

    private func memberFromData(id: String, data: [String: Any]) -> Member {
        Member(
            id: id,
            name: data["name"] as? String ?? "",
            profileImageURL: data["profileImageURL"] as? String,
            role: Member.Role(rawValue: data["role"] as? String ?? "member") ?? .member,
            rotationOrder: data["rotationOrder"] as? Int ?? 0,
            joinedAt: (data["joinedAt"] as? Timestamp)?.dateValue() ?? Date()
        )
    }
}
