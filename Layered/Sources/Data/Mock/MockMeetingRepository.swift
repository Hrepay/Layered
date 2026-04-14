import Foundation

final class MockMeetingRepository: MeetingRepositoryProtocol {
    func createMeeting(familyId: String, meeting: Meeting) async throws -> Meeting {
        meeting
    }

    func getMeetings(familyId: String) async throws -> [Meeting] {
        MockData.meetings
    }

    func getMeeting(familyId: String, meetingId: String) async throws -> Meeting {
        MockData.meetings.first { $0.id == meetingId } ?? MockData.meetings[0]
    }

    func updateMeeting(familyId: String, meeting: Meeting) async throws {}

    func deleteMeeting(familyId: String, meetingId: String) async throws {}
}
