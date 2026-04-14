import Foundation

protocol RecordRepositoryProtocol {
    func createRecord(familyId: String, meetingId: String, record: MeetingRecord) async throws -> MeetingRecord
    func getRecords(familyId: String, meetingId: String) async throws -> [MeetingRecord]
    func updateRecord(familyId: String, meetingId: String, record: MeetingRecord) async throws
    func deleteRecord(familyId: String, meetingId: String, recordId: String) async throws
}
