import Foundation

enum MockData {
    // MARK: - Users
    static let currentUser = User(
        id: "user-001",
        name: "상환",
        profileImageURL: nil,
        familyId: "family-001",
        createdAt: Date()
    )

    // MARK: - Family
    static let family = Family(
        id: "family-001",
        name: "황씨네",
        inviteCode: "ABC123",
        inviteCodeExpiresAt: Date().addingTimeInterval(1800),
        adminId: "user-001",
        memberCount: 3,
        currentPlannerIndex: 0,
        rotationDay: 1,
        rotationMode: "auto",
        createdAt: Date()
    )

    // MARK: - Members
    static let members: [Member] = [
        Member(
            id: "user-001",
            name: "상환",
            profileImageURL: nil,
            role: .admin,
            rotationOrder: 0,
            joinedAt: Date()
        ),
        Member(
            id: "user-002",
            name: "엄마",
            profileImageURL: nil,
            role: .member,
            rotationOrder: 1,
            joinedAt: Date()
        ),
        Member(
            id: "user-003",
            name: "아빠",
            profileImageURL: nil,
            role: .member,
            rotationOrder: 2,
            joinedAt: Date()
        ),
    ]

    // MARK: - Meetings
    static let meetings: [Meeting] = [
        Meeting(
            id: "meeting-001",
            plannerId: "user-001",
            plannerName: "상환",
            meetingDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())!,
            place: "한강공원",
            placeLatitude: 37.5283,
            placeLongitude: 126.9346,
            placeURL: nil,
            activity: "피크닉 + 자전거 타기",
            status: .confirmed,
            hasPoll: true,
            createdAt: Date(),
            updatedAt: Date()
        ),
        Meeting(
            id: "meeting-002",
            plannerId: "user-002",
            plannerName: "엄마",
            meetingDate: Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
            place: "강남 맛집",
            placeLatitude: 37.4979,
            placeLongitude: 127.0276,
            placeURL: nil,
            activity: "저녁 식사",
            status: .completed,
            hasPoll: false,
            createdAt: Date(),
            updatedAt: Date()
        ),
    ]

    // MARK: - Poll
    static let poll = Poll(
        id: "poll-001",
        question: "어디로 갈까요?",
        isAnonymous: false,
        allowMultiple: false,
        options: [
            PollOption(id: "opt-1", title: "한강공원", description: "피크닉하기 좋은 날씨", imageURL: nil, voterIds: ["user-001"], voteCount: 1),
            PollOption(id: "opt-2", title: "북한산", description: "등산하기", imageURL: nil, voterIds: ["user-002", "user-003"], voteCount: 2),
            PollOption(id: "opt-3", title: "롯데월드", description: "놀이공원", imageURL: nil, voterIds: [], voteCount: 0),
        ],
        createdAt: Date()
    )

    // MARK: - Records
    static let records: [MeetingRecord] = [
        MeetingRecord(
            id: "record-001",
            memberId: "user-001",
            memberName: "상환",
            photos: [],
            comment: "오늘 너무 재밌었다! 다음에도 또 가자",
            rating: 5,
            createdAt: Date(),
            updatedAt: Date()
        ),
        MeetingRecord(
            id: "record-002",
            memberId: "user-002",
            memberName: "엄마",
            photos: [],
            comment: "음식이 맛있었어요",
            rating: 4,
            createdAt: Date(),
            updatedAt: Date()
        ),
    ]
}
