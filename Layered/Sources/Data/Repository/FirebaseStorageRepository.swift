import Foundation
import UIKit
import FirebaseStorage

final class FirebaseStorageRepository: StorageRepositoryProtocol {
    private let storage = Storage.storage()

    func uploadProfileImage(userId: String, imageData: Data) async throws -> String {
        let path = "users/\(userId)/profile.jpg"
        return try await uploadData(imageData, path: path)
    }

    func uploadRecordPhoto(familyId: String, meetingId: String, recordId: String, index: Int, imageData: Data) async throws -> String {
        let path = "families/\(familyId)/meetings/\(meetingId)/records/\(recordId)/photo_\(index).jpg"
        return try await uploadData(imageData, path: path)
    }

    func deleteImage(path: String) async throws {
        let ref = storage.reference().child(path)
        try await ref.delete()
    }

    // MARK: - Private

    private func uploadData(_ data: Data, path: String) async throws -> String {
        let ref = storage.reference().child(path)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        _ = try await ref.putDataAsync(data, metadata: metadata)
        let url = try await ref.downloadURL()
        return url.absoluteString
    }

}
