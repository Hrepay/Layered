import Foundation

final class MockPollRepository: PollRepositoryProtocol {
    func createPoll(familyId: String, meetingId: String, poll: Poll) async throws -> Poll {
        poll
    }

    func getPoll(familyId: String, meetingId: String, pollId: String) async throws -> Poll {
        MockData.poll
    }

    func vote(familyId: String, meetingId: String, pollId: String, optionId: String, userId: String) async throws {}

    func removeVote(familyId: String, meetingId: String, pollId: String, optionId: String, userId: String) async throws {}

    func closePoll(familyId: String, meetingId: String, pollId: String) async throws {}

    func deletePoll(familyId: String, meetingId: String, pollId: String) async throws {}
}
