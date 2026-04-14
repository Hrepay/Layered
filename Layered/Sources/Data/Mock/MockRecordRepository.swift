import Foundation

final class MockRecordRepository: RecordRepositoryProtocol {
    func createRecord(familyId: String, meetingId: String, record: MeetingRecord) async throws -> MeetingRecord {
        record
    }

    func getRecords(familyId: String, meetingId: String) async throws -> [MeetingRecord] {
        MockData.records
    }

    func updateRecord(familyId: String, meetingId: String, record: MeetingRecord) async throws {}

    func deleteRecord(familyId: String, meetingId: String, recordId: String) async throws {}
}
