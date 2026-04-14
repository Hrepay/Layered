import SwiftUI
import UIKit
import FirebaseAuth

enum AuthState: Equatable {
    case splash
    case onboarding
    case login
    case familySetup
    case home
}

@Observable
final class AppState {
    var authState: AuthState = .splash
    var currentUser: User?
    var currentFamily: Family?
    var members: [Member] = []
    var meetings: [Meeting] = []
    var myRecordedMeetingIds: Set<String> = []
    var averageRating: Double = 0
    var consecutiveWeeks: Int = 0
    var isLoading = false
    var errorMessage: String?

    // @Observable은 lazy를 지원하지 않으므로 nonisolated(unsafe)로 선언
    nonisolated(unsafe) private var _authRepository: AuthRepositoryProtocol?
    nonisolated(unsafe) private var _userRepository: UserRepositoryProtocol?
    nonisolated(unsafe) private var _familyRepository: FamilyRepositoryProtocol?
    nonisolated(unsafe) private var _memberRepository: MemberRepositoryProtocol?
    nonisolated(unsafe) private var _meetingRepository: MeetingRepositoryProtocol?
    nonisolated(unsafe) private var _pollRepository: PollRepositoryProtocol?
    nonisolated(unsafe) private var _recordRepository: RecordRepositoryProtocol?
    nonisolated(unsafe) private var _storageRepository: StorageRepositoryProtocol?

    private var authRepository: AuthRepositoryProtocol {
        if _authRepository == nil { _authRepository = FirebaseAuthRepository() }
        return _authRepository!
    }
    var userRepository: UserRepositoryProtocol {
        if _userRepository == nil { _userRepository = FirebaseUserRepository() }
        return _userRepository!
    }
    var familyRepository: FamilyRepositoryProtocol {
        if _familyRepository == nil { _familyRepository = FirebaseFamilyRepository() }
        return _familyRepository!
    }
    var memberRepository: MemberRepositoryProtocol {
        if _memberRepository == nil { _memberRepository = FirebaseMemberRepository() }
        return _memberRepository!
    }
    var meetingRepository: MeetingRepositoryProtocol {
        if _meetingRepository == nil { _meetingRepository = FirebaseMeetingRepository() }
        return _meetingRepository!
    }
    var pollRepository: PollRepositoryProtocol {
        if _pollRepository == nil { _pollRepository = FirebasePollRepository() }
        return _pollRepository!
    }
    var recordRepository: RecordRepositoryProtocol {
        if _recordRepository == nil { _recordRepository = FirebaseRecordRepository() }
        return _recordRepository!
    }
    var storageRepository: StorageRepositoryProtocol {
        if _storageRepository == nil { _storageRepository = FirebaseStorageRepository() }
        return _storageRepository!
    }

    private var hasSeenOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: "hasSeenOnboarding") }
        set { UserDefaults.standard.set(newValue, forKey: "hasSeenOnboarding") }
    }

    // MARK: - 스플래시 후 상태 결정
    func checkAuthState() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if let firebaseUser = Auth.auth().currentUser {
                Task { @MainActor in
                    await self.loadUserData(uid: firebaseUser.uid)
                }
            } else if self.hasSeenOnboarding {
                self.authState = .login
            } else {
                self.authState = .onboarding
            }
        }
    }

    // MARK: - 온보딩 완료
    func completeOnboarding() {
        hasSeenOnboarding = true
        authState = .login
    }

    // MARK: - 이메일 로그인 (디버그용)
    #if DEBUG
    func signInWithEmail(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            let uid = result.user.uid
            let user = User(
                id: uid,
                name: result.user.displayName ?? email.components(separatedBy: "@").first ?? "테스터",
                profileImageURL: nil,
                familyId: nil,
                createdAt: Date()
            )
            try await userRepository.createUserIfNeeded(user)
            await loadUserData(uid: uid)
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    #endif

    // MARK: - Apple 로그인
    func signInWithApple() async {
        isLoading = true
        errorMessage = nil
        do {
            let user = try await authRepository.signInWithApple()
            try await userRepository.createUserIfNeeded(user)
            await loadUserData(uid: user.id)
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    // MARK: - 유저 데이터 로드 → 화면 분기
    @MainActor
    private func loadUserData(uid: String) async {
        isLoading = true
        do {
            let user = try await userRepository.getUser(id: uid)
            currentUser = user

            if let familyId = user.familyId {
                let family = try await familyRepository.getFamily(id: familyId)
                currentFamily = family
                await loadHomeData()
                authState = .home
            } else {
                authState = .familySetup
            }
        } catch {
            let newUser = User(
                id: uid,
                name: Auth.auth().currentUser?.displayName ?? "사용자",
                profileImageURL: nil,
                familyId: nil,
                createdAt: Date()
            )
            try? await userRepository.createUserIfNeeded(newUser)
            currentUser = newUser
            authState = .familySetup
        }
        isLoading = false
    }

    // MARK: - 가정 참여 완료
    func joinedFamily(_ family: Family) {
        currentFamily = family
        if let user = currentUser {
            Task {
                var updatedUser = user
                updatedUser.familyId = family.id
                try? await userRepository.updateUser(updatedUser)
                await loadHomeData()
            }
        }
        authState = .home
    }

    // MARK: - 홈 데이터 로드
    @MainActor
    func loadHomeData() async {
        guard let familyId = currentFamily?.id else { return }
        do {
            async let membersTask = memberRepository.getMembers(familyId: familyId)
            async let meetingsTask = meetingRepository.getMeetings(familyId: familyId)
            let (loadedMembers, loadedMeetings) = try await (membersTask, meetingsTask)
            members = loadedMembers
            meetings = loadedMeetings
            await checkMyRecords()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    func checkMyRecords() async {
        guard let familyId = currentFamily?.id,
              let userId = currentUser?.id else { return }
        var recordedIds = Set<String>()
        var allRatings: [Int] = []
        for meeting in meetings {
            if let records = try? await recordRepository.getRecords(familyId: familyId, meetingId: meeting.id) {
                if records.contains(where: { $0.memberId == userId }) {
                    recordedIds.insert(meeting.id)
                }
                allRatings.append(contentsOf: records.map(\.rating))
            }
        }
        myRecordedMeetingIds = recordedIds
        averageRating = allRatings.isEmpty ? 0 : Double(allRatings.reduce(0, +)) / Double(allRatings.count)
        consecutiveWeeks = calcConsecutiveWeeks()
    }

    private func calcConsecutiveWeeks() -> Int {
        let calendar = Calendar.current
        let now = Date()

        // 모임 날짜에서 주 번호 추출 (과거 모임만)
        let meetingWeeks = Set(
            meetings
                .filter { $0.meetingDate <= now && $0.status != .cancelled }
                .map { calendar.component(.weekOfYear, from: $0.meetingDate) * 10000 + calendar.component(.yearForWeekOfYear, from: $0.meetingDate) }
        )

        guard !meetingWeeks.isEmpty else { return 0 }

        // 현재 주부터 과거로 연속 체크
        var streak = 0
        var checkDate = now

        while true {
            let week = calendar.component(.weekOfYear, from: checkDate)
            let year = calendar.component(.yearForWeekOfYear, from: checkDate)
            let key = week * 10000 + year

            if meetingWeeks.contains(key) {
                streak += 1
                checkDate = calendar.date(byAdding: .weekOfYear, value: -1, to: checkDate)!
            } else {
                break
            }
        }

        return streak
    }

    @MainActor
    func refreshMeetings() async {
        guard let familyId = currentFamily?.id else { return }
        do {
            meetings = try await meetingRepository.getMeetings(familyId: familyId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    func refreshMembers() async {
        guard let familyId = currentFamily?.id else { return }
        do {
            members = try await memberRepository.getMembers(familyId: familyId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - 모임 CRUD
    func createMeeting(_ meeting: Meeting) async throws -> Meeting {
        guard let familyId = currentFamily?.id else { throw AppStateError.noFamily }
        let created = try await meetingRepository.createMeeting(familyId: familyId, meeting: meeting)
        await refreshMeetings()
        return created
    }

    func updateMeeting(_ meeting: Meeting) async throws {
        guard let familyId = currentFamily?.id else { throw AppStateError.noFamily }
        try await meetingRepository.updateMeeting(familyId: familyId, meeting: meeting)
        await refreshMeetings()
    }

    func deleteMeeting(_ meetingId: String) async throws {
        guard let familyId = currentFamily?.id else { throw AppStateError.noFamily }
        try await meetingRepository.deleteMeeting(familyId: familyId, meetingId: meetingId)
        await refreshMeetings()
    }

    // MARK: - 투표 CRUD
    func createPoll(meetingId: String, poll: Poll) async throws -> Poll {
        guard let familyId = currentFamily?.id else { throw AppStateError.noFamily }
        let created = try await pollRepository.createPoll(familyId: familyId, meetingId: meetingId, poll: poll)
        await refreshMeetings()
        return created
    }

    func vote(meetingId: String, pollId: String, optionId: String) async throws {
        guard let familyId = currentFamily?.id,
              let userId = currentUser?.id else { throw AppStateError.noFamily }
        try await pollRepository.vote(familyId: familyId, meetingId: meetingId, pollId: pollId, optionId: optionId, userId: userId)
    }

    func removeVote(meetingId: String, pollId: String, optionId: String) async throws {
        guard let familyId = currentFamily?.id,
              let userId = currentUser?.id else { throw AppStateError.noFamily }
        try await pollRepository.removeVote(familyId: familyId, meetingId: meetingId, pollId: pollId, optionId: optionId, userId: userId)
    }

    func getPolls(meetingId: String) async throws -> [Poll] {
        guard let familyId = currentFamily?.id else { throw AppStateError.noFamily }
        return try await pollRepository.getPolls(familyId: familyId, meetingId: meetingId)
    }

    func getPoll(meetingId: String, pollId: String) async throws -> Poll {
        guard let familyId = currentFamily?.id else { throw AppStateError.noFamily }
        return try await pollRepository.getPoll(familyId: familyId, meetingId: meetingId, pollId: pollId)
    }

    func closePoll(meetingId: String, pollId: String) async throws {
        guard let familyId = currentFamily?.id else { throw AppStateError.noFamily }
        try await pollRepository.closePoll(familyId: familyId, meetingId: meetingId, pollId: pollId)
    }

    func deletePoll(meetingId: String, pollId: String) async throws {
        guard let familyId = currentFamily?.id else { throw AppStateError.noFamily }
        try await pollRepository.deletePoll(familyId: familyId, meetingId: meetingId, pollId: pollId)
        await refreshMeetings()
    }

    // MARK: - 기록 CRUD
    @MainActor
    func createRecord(meetingId: String, record: MeetingRecord) async throws -> MeetingRecord {
        guard let familyId = currentFamily?.id else { throw AppStateError.noFamily }
        let created = try await recordRepository.createRecord(familyId: familyId, meetingId: meetingId, record: record)
        myRecordedMeetingIds.insert(meetingId)
        return created
    }

    func getRecords(meetingId: String) async throws -> [MeetingRecord] {
        guard let familyId = currentFamily?.id else { throw AppStateError.noFamily }
        return try await recordRepository.getRecords(familyId: familyId, meetingId: meetingId)
    }

    func updateRecord(meetingId: String, record: MeetingRecord) async throws {
        guard let familyId = currentFamily?.id else { throw AppStateError.noFamily }
        try await recordRepository.updateRecord(familyId: familyId, meetingId: meetingId, record: record)
    }

    func deleteRecord(meetingId: String, recordId: String) async throws {
        guard let familyId = currentFamily?.id else { throw AppStateError.noFamily }
        try await recordRepository.deleteRecord(familyId: familyId, meetingId: meetingId, recordId: recordId)
    }

    // MARK: - 구성원 관리
    func removeMember(_ memberId: String) async throws {
        guard let familyId = currentFamily?.id else { throw AppStateError.noFamily }
        try await memberRepository.removeMember(familyId: familyId, memberId: memberId)
        await refreshMembers()
    }

    func updateRotationOrder(_ memberOrders: [(memberId: String, order: Int)]) async throws {
        guard let familyId = currentFamily?.id else { throw AppStateError.noFamily }
        try await memberRepository.updateRotationOrder(familyId: familyId, memberOrders: memberOrders)
        await refreshMembers()
    }

    // MARK: - 가정 관리
    func generateInviteCode() async throws -> String {
        guard let familyId = currentFamily?.id else { throw AppStateError.noFamily }
        return try await familyRepository.generateInviteCode(familyId: familyId)
    }

    func leaveFamily() async throws {
        guard let familyId = currentFamily?.id,
              let userId = currentUser?.id else { throw AppStateError.noFamily }
        try await memberRepository.removeMember(familyId: familyId, memberId: userId)
        var updatedUser = currentUser!
        updatedUser.familyId = nil
        try await userRepository.updateUser(updatedUser)
        currentUser = updatedUser
        currentFamily = nil
        members = []
        meetings = []
        authState = .familySetup
    }

    func deleteFamily() async throws {
        guard let familyId = currentFamily?.id else { throw AppStateError.noFamily }
        try await familyRepository.deleteFamily(id: familyId)
        var updatedUser = currentUser!
        updatedUser.familyId = nil
        try await userRepository.updateUser(updatedUser)
        currentUser = updatedUser
        currentFamily = nil
        members = []
        meetings = []
        authState = .familySetup
    }

    // MARK: - 프로필 수정
    // MARK: - 가정 이름 변경
    @MainActor
    func updateFamilyName(_ name: String) async throws {
        guard let familyId = currentFamily?.id else { throw AppStateError.noFamily }
        try await familyRepository.updateFamilyName(familyId: familyId, name: name)
        currentFamily?.name = name
    }

    @MainActor
    func updateProfile(name: String, profileImageURL: String?) async throws {
        guard var user = currentUser else { return }
        user.name = name
        user.profileImageURL = profileImageURL
        try await userRepository.updateUser(user)
        currentUser = user
    }

    // MARK: - 프로필 사진 업로드
    func uploadProfileImage(_ image: UIImage) async throws {
        guard var user = currentUser else { return }
        guard let data = FirebaseStorageRepository.resizeAndCompress(image, maxSize: 256, quality: 0.5) else { return }
        let url = try await storageRepository.uploadProfileImage(userId: user.id, imageData: data)
        user.profileImageURL = url
        try await userRepository.updateUser(user)
        currentUser = user
    }

    // MARK: - 로그아웃
    func signOut() {
        try? authRepository.signOut()
        currentUser = nil
        currentFamily = nil
        members = []
        meetings = []
        authState = .login
    }

    // MARK: - 계정 삭제
    func deleteAccount() async {
        isLoading = true
        do {
            try await authRepository.deleteAccount()
            currentUser = nil
            currentFamily = nil
            members = []
            meetings = []
            authState = .login
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

// MARK: - AppState Error
enum AppStateError: LocalizedError {
    case noFamily

    var errorDescription: String? {
        switch self {
        case .noFamily: return "가정 정보를 찾을 수 없습니다"
        }
    }
}
