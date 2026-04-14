import Foundation

protocol MeetingRepositoryProtocol {
    func createMeeting(familyId: String, meeting: Meeting) async throws -> Meeting
    func getMeetings(familyId: String) async throws -> [Meeting]
    func getMeeting(familyId: String, meetingId: String) async throws -> Meeting
    func updateMeeting(familyId: String, meeting: Meeting) async throws
    func deleteMeeting(familyId: String, meetingId: String) async throws
}
