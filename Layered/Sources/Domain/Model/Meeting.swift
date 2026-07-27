import Foundation

struct Meeting: Identifiable, Codable, Hashable {
    let id: String
    var plannerId: String
    var plannerName: String
    var meetingDate: Date
    /// 여행(1박 이상) 종료일. nil이면 기존과 같은 당일 모임 — 과거 데이터와 자연 호환.
    var endDate: Date? = nil
    var place: String
    /// 카카오 장소 ID — 검색으로 고른 경우에만. 위시리스트 매칭·일정표 재사용 키.
    var placeId: String? = nil
    var placeLatitude: Double?
    var placeLongitude: Double?
    var placeURL: String?
    var activity: String?
    var status: Status
    var hasPoll: Bool
    /// 모임 참여자(가족 멤버 id) 명단. 비어 있으면 "가족 전원"으로 간주 — 이 필드가
    /// 없던 시절에 만들어진 모임과의 호환을 위해 폴백 의미를 둔다.
    var participantIds: [String] = []
    /// 멤버 id → 참석 상태. 맵에 없는 멤버는 `미정`(참석 예정·미확정).
    var attendance: [String: AttendanceStatus] = [:]
    let createdAt: Date
    var updatedAt: Date
    /// 가장 최근 EditMeetingView·후보 확정 등 "수정"으로 간주되는 액션이 일어난 시각.
    /// 출석 변경·콕 찌르기 같은 운영성 변경은 updatedAt만 갱신하고 이 필드는 건드리지 않는다.
    var lastEditedAt: Date? = nil
    var lastEditedById: String? = nil
    /// 표시용 비정규화 이름. 변경 시점의 사용자명을 박제 — 이후 가족에서 나가도 표시 유지.
    var lastEditedByName: String? = nil

    enum Status: String, Codable {
        case planning
        case confirmed
        case completed
        case cancelled
    }

    enum AttendanceStatus: String, Codable {
        case going
        case notGoing
    }
}

extension Meeting {
    /// UI 표시용 장소명. 투표 모드(후보 단계)면 placeholder로 대체.
    var displayPlace: String {
        if hasPoll && place.isEmpty { return "장소 투표 중" }
        return place
    }

    /// 1박 이상 여행인지.
    var isTrip: Bool { endDate != nil }

    /// 여행 일수 (2박 3일이면 3). 당일 모임은 1.
    var durationDays: Int {
        guard let endDate else { return 1 }
        let calendar = Calendar.current
        let days = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: meetingDate),
            to: calendar.startOfDay(for: endDate)
        ).day ?? 0
        return max(1, days + 1)
    }

    /// 모임이 "끝나는" 시점 — 다가오는/지난 판정용.
    /// 당일 모임은 시작 시각, 여행은 종료일이 지나는 자정.
    var effectiveEndDate: Date {
        guard let endDate else { return meetingDate }
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: endDate)) ?? endDate
    }

    /// 여행 진행 중인지 (시작일 0시 ~ 종료일 자정).
    var isTripInProgress: Bool {
        guard isTrip else { return false }
        let now = Date()
        return Calendar.current.startOfDay(for: meetingDate) <= now && now < effectiveEndDate
    }

    /// 실제 참여자 id. 명단이 비어 있으면(레거시 모임) 가족 전원으로 폴백.
    func effectiveParticipantIds(allMemberIds: [String]) -> [String] {
        participantIds.isEmpty ? allMemberIds : participantIds
    }

    func attendanceStatus(for memberId: String) -> AttendanceStatus? {
        attendance[memberId]
    }
}
