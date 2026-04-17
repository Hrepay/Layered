import Foundation

enum MockData {
    // MARK: - Helpers

    private static let calendar = Calendar.current

    private static func daysFromNow(_ days: Int, hour: Int = 18, minute: Int = 0) -> Date {
        let base = calendar.date(byAdding: .day, value: days, to: Date()) ?? Date()
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: base) ?? base
    }

    // MARK: - Users
    static let currentUser = User(
        id: "user-001",
        name: "상환",
        profileImageURL: "https://picsum.photos/seed/hrepay-me/400/400",
        familyId: "family-001",
        createdAt: daysFromNow(-120),
        agreedTermsAt: daysFromNow(-120),
        agreedTermsVersion: "1.0",
        marketingConsent: true
    )

    // MARK: - Family
    static let family = Family(
        id: "family-001",
        name: "황씨네",
        inviteCode: "HRPY26",
        inviteCodeExpiresAt: Date().addingTimeInterval(1500),
        adminId: "user-001",
        memberCount: 4,
        currentPlannerIndex: 0,
        rotationDay: 1,
        rotationMode: "auto",
        createdAt: daysFromNow(-180)
    )

    // MARK: - Members
    static let members: [Member] = [
        Member(
            id: "user-001",
            name: "상환",
            profileImageURL: "https://picsum.photos/seed/hrepay-me/400/400",
            role: .admin,
            rotationOrder: 0,
            joinedAt: daysFromNow(-180)
        ),
        Member(
            id: "user-002",
            name: "엄마",
            profileImageURL: "https://picsum.photos/seed/hrepay-mom/400/400",
            role: .member,
            rotationOrder: 1,
            joinedAt: daysFromNow(-180)
        ),
        Member(
            id: "user-003",
            name: "아빠",
            profileImageURL: "https://picsum.photos/seed/hrepay-dad/400/400",
            role: .member,
            rotationOrder: 2,
            joinedAt: daysFromNow(-180)
        ),
        Member(
            id: "user-004",
            name: "누나",
            profileImageURL: "https://picsum.photos/seed/hrepay-sis/400/400",
            role: .member,
            rotationOrder: 3,
            joinedAt: daysFromNow(-150)
        ),
    ]

    // MARK: - Meetings
    static let meetings: [Meeting] = [
        // 이번 주 예정 모임
        Meeting(
            id: "meeting-upcoming",
            plannerId: "user-001",
            plannerName: "상환",
            meetingDate: daysFromNow(3, hour: 17, minute: 30),
            place: "한강공원 뚝섬지구",
            placeLatitude: 37.5316,
            placeLongitude: 127.0688,
            placeURL: "https://map.naver.com/v5/entry/place/11557509",
            activity: "피크닉, 산책, 자전거",
            status: .confirmed,
            hasPoll: true,
            createdAt: daysFromNow(-2),
            updatedAt: daysFromNow(-1)
        ),
        // 지난 모임 1
        Meeting(
            id: "meeting-past-1",
            plannerId: "user-002",
            plannerName: "엄마",
            meetingDate: daysFromNow(-5, hour: 19, minute: 0),
            place: "성수동 감자탕",
            placeLatitude: 37.5446,
            placeLongitude: 127.0561,
            placeURL: "https://map.naver.com/v5/search/성수동 감자탕",
            activity: "외식",
            status: .completed,
            hasPoll: false,
            createdAt: daysFromNow(-12),
            updatedAt: daysFromNow(-5)
        ),
        // 지난 모임 2
        Meeting(
            id: "meeting-past-2",
            plannerId: "user-003",
            plannerName: "아빠",
            meetingDate: daysFromNow(-12, hour: 10, minute: 0),
            place: "북한산 둘레길",
            placeLatitude: 37.6588,
            placeLongitude: 126.9779,
            placeURL: nil,
            activity: "산책, 운동",
            status: .completed,
            hasPoll: false,
            createdAt: daysFromNow(-20),
            updatedAt: daysFromNow(-12)
        ),
        // 지난 모임 3
        Meeting(
            id: "meeting-past-3",
            plannerId: "user-004",
            plannerName: "누나",
            meetingDate: daysFromNow(-19, hour: 14, minute: 0),
            place: "연남동 카페",
            placeLatitude: 37.5623,
            placeLongitude: 126.9259,
            placeURL: nil,
            activity: "카페, 문화생활",
            status: .completed,
            hasPoll: false,
            createdAt: daysFromNow(-25),
            updatedAt: daysFromNow(-19)
        ),
    ]

    // MARK: - Poll (이번 주 예정 모임용)
    static let poll = Poll(
        id: "poll-001",
        question: "뭐 하고 놀까요?",
        isAnonymous: false,
        allowMultiple: true,
        options: [
            PollOption(
                id: "opt-1",
                title: "피크닉 + 자전거",
                description: nil,
                imageURL: nil,
                voterIds: ["user-001", "user-002", "user-004"],
                voteCount: 3
            ),
            PollOption(
                id: "opt-2",
                title: "배드민턴",
                description: nil,
                imageURL: nil,
                voterIds: ["user-003"],
                voteCount: 1
            ),
            PollOption(
                id: "opt-3",
                title: "강변 산책만",
                description: nil,
                imageURL: nil,
                voterIds: ["user-002"],
                voteCount: 1
            ),
        ],
        createdAt: daysFromNow(-1)
    )

    // MARK: - Records
    /// RecordDetailView가 단일 배열을 받는 구조이므로 가장 최근 지난 모임(`meeting-past-1`) 기록만 반환.
    static let records: [MeetingRecord] = [
        MeetingRecord(
            id: "record-001",
            memberId: "user-001",
            memberName: "상환",
            photos: [
                "https://picsum.photos/seed/layered-food1/800/800",
                "https://picsum.photos/seed/layered-food2/800/800",
            ],
            comment: "엄마가 추천한 집이라 기대했는데 역시 뼈해장국이 끝내줬다. 고기도 듬뿍.",
            rating: 5,
            createdAt: daysFromNow(-5, hour: 22),
            updatedAt: daysFromNow(-5, hour: 22)
        ),
        MeetingRecord(
            id: "record-002",
            memberId: "user-002",
            memberName: "엄마",
            photos: [
                "https://picsum.photos/seed/layered-food3/800/800",
            ],
            comment: "오랜만에 다 같이 모여서 좋았어. 다음엔 누나도 데려오자.",
            rating: 5,
            createdAt: daysFromNow(-5, hour: 21, minute: 30),
            updatedAt: daysFromNow(-5, hour: 21, minute: 30)
        ),
        MeetingRecord(
            id: "record-003",
            memberId: "user-003",
            memberName: "아빠",
            photos: [],
            comment: "양 많고 맛 좋음. 다음 모임도 여기로 가자.",
            rating: 4,
            createdAt: daysFromNow(-4, hour: 20),
            updatedAt: daysFromNow(-4, hour: 20)
        ),
    ]
}
