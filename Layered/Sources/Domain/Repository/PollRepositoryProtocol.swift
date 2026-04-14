import Foundation

protocol PollRepositoryProtocol {
    func createPoll(familyId: String, meetingId: String, poll: Poll) async throws -> Poll
    func getPolls(familyId: String, meetingId: String) async throws -> [Poll]
    func getPoll(familyId: String, meetingId: String, pollId: String) async throws -> Poll
    func vote(familyId: String, meetingId: String, pollId: String, optionId: String, userId: String) async throws
    func removeVote(familyId: String, meetingId: String, pollId: String, optionId: String, userId: String) async throws
    func closePoll(familyId: String, meetingId: String, pollId: String) async throws
    func deletePoll(familyId: String, meetingId: String, pollId: String) async throws
}
