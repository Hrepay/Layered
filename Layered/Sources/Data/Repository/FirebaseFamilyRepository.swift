import Foundation
import FirebaseFirestore
import FirebaseStorage

final class FirebaseFamilyRepository: FamilyRepositoryProtocol {
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
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
            "rotationMode": "auto",
            "createdAt": Timestamp(date: Date()),
        ]

        let docRef = familiesRef.document()
        try await docRef.setData(familyData)

        // 생성자를 첫 번째 멤버로 추가
        let usersRef = db.collection("users")
        let userDoc = try await usersRef.document(adminId).getDocument()
        let userData = userDoc.data()
        let userName = userData?["name"] as? String ?? "사용자"
        let userImageURL = userData?["profileImageURL"] as? String

        try await docRef.collection("members").document(adminId).setData([
            "name": userName,
            "profileImageURL": userImageURL as Any,
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
            rotationMode: "auto",
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
        let familyRef = familiesRef.document(id)

        // 1. meetings 전체 순회 — 각 모임의 polls·records·사진까지 cascade 삭제
        let meetingsSnapshot = try await familyRef.collection("meetings").getDocuments()
        for meetingDoc in meetingsSnapshot.documents {
            let meetingRef = meetingDoc.reference

            // polls 삭제
            let pollsSnapshot = try? await meetingRef.collection("polls").getDocuments()
            for pollDoc in pollsSnapshot?.documents ?? [] {
                try? await pollDoc.reference.delete()
            }

            // records 사진 + 문서 삭제
            let recordsSnapshot = try? await meetingRef.collection("records").getDocuments()
            for recordDoc in recordsSnapshot?.documents ?? [] {
                if let photos = recordDoc.data()["photos"] as? [String] {
                    for urlString in photos {
                        try? await deletePhotoByURL(urlString)
                    }
                }
                try? await recordDoc.reference.delete()
            }

            // 모임 문서 삭제
            try? await meetingRef.delete()
        }

        // 2. members 순회 — 각 유저의 familyId 초기화 + 멤버 문서 삭제
        let membersSnapshot = try await familyRef.collection("members").getDocuments()
        for memberDoc in membersSnapshot.documents {
            // 유저 문서의 familyId 제거 (규칙상 본인만 쓸 수 있으나, 탈퇴 시 관리자가 일괄 처리)
            try? await db.collection("users").document(memberDoc.documentID).updateData([
                "familyId": FieldValue.delete()
            ])
            try? await memberDoc.reference.delete()
        }

        // 3. family 문서 삭제
        try await familyRef.delete()
    }

    /// Firebase Storage 다운로드 URL로부터 참조를 구성해 삭제.
    private func deletePhotoByURL(_ urlString: String) async throws {
        guard urlString.contains("firebasestorage") else { return }
        let ref = storage.reference(forURL: urlString)
        try await ref.delete()
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

        // users에서 프로필 이미지 가져오기
        let userDoc = try await db.collection("users").document(userId).getDocument()
        let userImageURL = userDoc.data()?["profileImageURL"] as? String

        // 멤버 추가
        try await familiesRef.document(familyId).collection("members").document(userId).setData([
            "name": userName,
            "profileImageURL": userImageURL as Any,
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

    func updateRotationMode(familyId: String, mode: String) async throws {
        try await familiesRef.document(familyId).updateData(["rotationMode": mode])
    }

    func updateCurrentPlannerIndex(familyId: String, index: Int) async throws {
        try await familiesRef.document(familyId).updateData(["currentPlannerIndex": index])
    }

    // MARK: - Helpers
    private func generateCode() -> String {
        let chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in chars.randomElement() ?? "0" })
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
            rotationMode: data["rotationMode"] as? String ?? "auto",
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        )
    }
}
