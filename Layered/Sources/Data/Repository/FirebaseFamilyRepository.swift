import Foundation
import FirebaseFirestore

final class FirebaseFamilyRepository: FamilyRepositoryProtocol {
    private let db = Firestore.firestore()
    private var familiesRef: CollectionReference { db.collection("families") }

    func createFamily(name: String, adminId: String) async throws -> Family {
        let inviteCode = generateCode()
        let familyData: [String: Any] = [
            "name": name,
            "inviteCode": inviteCode,
            "inviteCodeExpiresAt": Timestamp(date: Date().addingTimeInterval(1800)),
            "adminId": adminId,
            "memberCount": 1,
            "currentPlannerIndex": 0,
            "rotationDay": 1,
            "createdAt": Timestamp(date: Date()),
        ]

        let docRef = familiesRef.document()
        try await docRef.setData(familyData)

        // 생성자를 첫 번째 멤버로 추가
        let usersRef = db.collection("users")
        let userDoc = try await usersRef.document(adminId).getDocument()
        let userName = userDoc.data()?["name"] as? String ?? "사용자"

        try await docRef.collection("members").document(adminId).setData([
            "name": userName,
            "profileImageURL": NSNull(),
            "role": "admin",
            "rotationOrder": 0,
            "joinedAt": Timestamp(date: Date()),
        ])

        // User의 familyId 업데이트
        try await usersRef.document(adminId).updateData(["familyId": docRef.documentID])

        return Family(
            id: docRef.documentID,
            name: name,
            inviteCode: inviteCode,
            inviteCodeExpiresAt: Date().addingTimeInterval(1800),
            adminId: adminId,
            memberCount: 1,
            currentPlannerIndex: 0,
            rotationDay: 1,
            createdAt: Date()
        )
    }

    func getFamily(id: String) async throws -> Family {
        let doc = try await familiesRef.document(id).getDocument()
        guard let data = doc.data() else {
            throw NSError(domain: "family", code: -1, userInfo: [NSLocalizedDescriptionKey: "가정을 찾을 수 없습니다"])
        }
        return familyFromData(id: doc.documentID, data: data)
    }

    func deleteFamily(id: String) async throws {
        try await familiesRef.document(id).delete()
    }

    func updateFamilyName(familyId: String, name: String) async throws {
        try await familiesRef.document(familyId).updateData(["name": name])
    }

    func generateInviteCode(familyId: String) async throws -> String {
        let code = generateCode()
        let expiresAt = Date().addingTimeInterval(1800)
        try await familiesRef.document(familyId).updateData([
            "inviteCode": code,
            "inviteCodeExpiresAt": Timestamp(date: expiresAt),
        ])
        return code
    }

    func verifyInviteCode(inviteCode: String) async throws -> Family {
        let snapshot = try await familiesRef
            .whereField("inviteCode", isEqualTo: inviteCode)
            .getDocuments()

        guard let doc = snapshot.documents.first else {
            throw NSError(domain: "family", code: -1, userInfo: [NSLocalizedDescriptionKey: "유효하지 않은 코드입니다"])
        }

        let data = doc.data()
        let expiresAt = (data["inviteCodeExpiresAt"] as? Timestamp)?.dateValue() ?? Date.distantPast
        guard expiresAt > Date() else {
            throw NSError(domain: "family", code: -2, userInfo: [NSLocalizedDescriptionKey: "만료된 초대 코드입니다"])
        }

        let memberCount = data["memberCount"] as? Int ?? 0
        guard memberCount < 10 else {
            throw NSError(domain: "family", code: -3, userInfo: [NSLocalizedDescriptionKey: "가정 최대 인원(10명)을 초과했습니다"])
        }

        return familyFromData(id: doc.documentID, data: data)
    }

    func joinFamily(familyId: String, userId: String, userName: String) async throws {
        let doc = try await familiesRef.document(familyId).getDocument()
        let memberCount = doc.data()?["memberCount"] as? Int ?? 0

        // 멤버 추가
        try await familiesRef.document(familyId).collection("members").document(userId).setData([
            "name": userName,
            "profileImageURL": NSNull(),
            "role": "member",
            "rotationOrder": memberCount,
            "joinedAt": Timestamp(date: Date()),
        ])

        // memberCount 증가 + User의 familyId 업데이트
        try await familiesRef.document(familyId).updateData([
            "memberCount": FieldValue.increment(Int64(1))
        ])
        try await db.collection("users").document(userId).updateData(["familyId": familyId])
    }

    // MARK: - Helpers
    private func generateCode() -> String {
        String((0..<6).map { _ in "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".randomElement()! })
    }

    private func familyFromData(id: String, data: [String: Any]) -> Family {
        Family(
            id: id,
            name: data["name"] as? String ?? "",
            inviteCode: data["inviteCode"] as? String ?? "",
            inviteCodeExpiresAt: (data["inviteCodeExpiresAt"] as? Timestamp)?.dateValue() ?? Date(),
            adminId: data["adminId"] as? String ?? "",
            memberCount: data["memberCount"] as? Int ?? 0,
            currentPlannerIndex: data["currentPlannerIndex"] as? Int ?? 0,
            rotationDay: data["rotationDay"] as? Int ?? 1,
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        )
    }
}
