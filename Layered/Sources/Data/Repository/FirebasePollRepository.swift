import Foundation
import FirebaseFirestore

final class FirebasePollRepository: PollRepositoryProtocol {
    private let db = Firestore.firestore()

    private func pollsRef(familyId: String, meetingId: String) -> CollectionReference {
        db.collection("families").document(familyId)
            .collection("meetings").document(meetingId)
            .collection("polls")
    }

    func createPoll(familyId: String, meetingId: String, poll: Poll) async throws -> Poll {
        let optionsData: [[String: Any]] = poll.options.map { option in
            [
                "id": option.id,
                "title": option.title,
                "description": option.description as Any,
                "imageURL": option.imageURL as Any,
                "voterIds": option.voterIds,
                "voteCount": option.voteCount,
            ]
        }

        let data: [String: Any] = [
            "question": poll.question,
            "isAnonymous": poll.isAnonymous,
            "allowMultiple": poll.allowMultiple,
            "deadline": Timestamp(date: poll.deadline),
            "status": poll.status.rawValue,
            "options": optionsData,
            "createdAt": Timestamp(date: Date()),
        ]

        let docRef = pollsRef(familyId: familyId, meetingId: meetingId).document()
        try await docRef.setData(data)

        // meeting.hasPoll = true
        try await db.collection("families").document(familyId)
            .collection("meetings").document(meetingId)
            .updateData(["hasPoll": true])

        return Poll(
            id: docRef.documentID,
            question: poll.question,
            isAnonymous: poll.isAnonymous,
            allowMultiple: poll.allowMultiple,
            deadline: poll.deadline,
            status: poll.status,
            options: poll.options,
            createdAt: Date()
        )
    }

    func getPoll(familyId: String, meetingId: String, pollId: String) async throws -> Poll {
        let doc = try await pollsRef(familyId: familyId, meetingId: meetingId).document(pollId).getDocument()
        guard let data = doc.data() else {
            throw NSError(domain: "poll", code: -1, userInfo: [NSLocalizedDescriptionKey: "투표를 찾을 수 없습니다"])
        }
        return pollFromData(id: doc.documentID, data: data)
    }

    func vote(familyId: String, meetingId: String, pollId: String, optionId: String, userId: String) async throws {
        let ref = pollsRef(familyId: familyId, meetingId: meetingId).document(pollId)
        let doc = try await ref.getDocument()
        guard var data = doc.data(),
              var options = data["options"] as? [[String: Any]] else { return }

        let isAnonymous = data["isAnonymous"] as? Bool ?? false

        for i in options.indices {
            guard let id = options[i]["id"] as? String, id == optionId else { continue }
            if isAnonymous {
                options[i]["voteCount"] = (options[i]["voteCount"] as? Int ?? 0) + 1
            } else {
                var voterIds = options[i]["voterIds"] as? [String] ?? []
                if !voterIds.contains(userId) {
                    voterIds.append(userId)
                    options[i]["voterIds"] = voterIds
                    options[i]["voteCount"] = voterIds.count
                }
            }
        }

        try await ref.updateData(["options": options])
    }

    func removeVote(familyId: String, meetingId: String, pollId: String, optionId: String, userId: String) async throws {
        let ref = pollsRef(familyId: familyId, meetingId: meetingId).document(pollId)
        let doc = try await ref.getDocument()
        guard var data = doc.data(),
              var options = data["options"] as? [[String: Any]] else { return }

        for i in options.indices {
            guard let id = options[i]["id"] as? String, id == optionId else { continue }
            var voterIds = options[i]["voterIds"] as? [String] ?? []
            voterIds.removeAll { $0 == userId }
            options[i]["voterIds"] = voterIds
            options[i]["voteCount"] = max(0, (options[i]["voteCount"] as? Int ?? 1) - 1)
        }

        try await ref.updateData(["options": options])
    }

    func closePoll(familyId: String, meetingId: String, pollId: String) async throws {
        try await pollsRef(familyId: familyId, meetingId: meetingId).document(pollId)
            .updateData(["status": "closed"])
    }

    func deletePoll(familyId: String, meetingId: String, pollId: String) async throws {
        try await pollsRef(familyId: familyId, meetingId: meetingId).document(pollId).delete()
        try await db.collection("families").document(familyId)
            .collection("meetings").document(meetingId)
            .updateData(["hasPoll": false])
    }

    // MARK: - Helpers
    private func pollFromData(id: String, data: [String: Any]) -> Poll {
        let optionsData = data["options"] as? [[String: Any]] ?? []
        let options = optionsData.map { opt in
            PollOption(
                id: opt["id"] as? String ?? UUID().uuidString,
                title: opt["title"] as? String ?? "",
                description: opt["description"] as? String,
                imageURL: opt["imageURL"] as? String,
                voterIds: opt["voterIds"] as? [String] ?? [],
                voteCount: opt["voteCount"] as? Int ?? 0
            )
        }

        return Poll(
            id: id,
            question: data["question"] as? String ?? "",
            isAnonymous: data["isAnonymous"] as? Bool ?? false,
            allowMultiple: data["allowMultiple"] as? Bool ?? false,
            deadline: (data["deadline"] as? Timestamp)?.dateValue() ?? Date(),
            status: Poll.Status(rawValue: data["status"] as? String ?? "open") ?? .open,
            options: options,
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        )
    }
}
