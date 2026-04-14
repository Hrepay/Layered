import Foundation
import FirebaseFirestore

final class FirebaseUserRepository: UserRepositoryProtocol {
    private let db = Firestore.firestore()
    private var usersRef: CollectionReference { db.collection("users") }

    func getUser(id: String) async throws -> User {
        let doc = try await usersRef.document(id).getDocument()
        guard let data = doc.data() else {
            throw NSError(domain: "user", code: -1, userInfo: [NSLocalizedDescriptionKey: "사용자를 찾을 수 없습니다"])
        }
        return userFromData(id: doc.documentID, data: data)
    }

    func createUserIfNeeded(_ user: User) async throws {
        let docRef = usersRef.document(user.id)
        let doc = try await docRef.getDocument()

        if !doc.exists {
            try await docRef.setData([
                "name": user.name,
                "profileImageURL": user.profileImageURL as Any,
                "familyId": user.familyId as Any,
                "createdAt": Timestamp(date: user.createdAt),
            ])
        }
    }

    func updateUser(_ user: User) async throws {
        try await usersRef.document(user.id).updateData([
            "name": user.name,
            "profileImageURL": user.profileImageURL as Any,
            "familyId": user.familyId as Any,
        ])
    }

    // MARK: - Helper
    private func userFromData(id: String, data: [String: Any]) -> User {
        User(
            id: id,
            name: data["name"] as? String ?? "사용자",
            profileImageURL: data["profileImageURL"] as? String,
            familyId: data["familyId"] as? String,
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        )
    }
}
