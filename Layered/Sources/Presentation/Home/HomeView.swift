import SwiftUI

struct HomeView: View {
    var family: Family
    var members: [Member]
    var meetings: [Meeting]
    var currentUser: User

    @Environment(AppState.self) private var appState: AppState?

    @State private var showMeetingDetail: Meeting?
    @State private var showCreateMeeting = false
    @State private var showCreateRecord: Meeting?
    @State private var showInvite = false
    @State private var toast: ToastData?
    @State private var dismissedRecordCard = false

    private var currentPlanner: Member? {
        guard !members.isEmpty,
              family.currentPlannerIndex < members.count else { return nil }
        return members[family.currentPlannerIndex]
    }

    private var isPlanner: Bool {
        currentPlanner?.id == currentUser.id
    }

    private var upcomingMeeting: Meeting? {
        meetings.first {
            ($0.status == .confirmed || $0.status == .planning)
            && $0.meetingDate > Date()
        }
    }

    private var pastMeeting: Meeting? {
        meetings.first {
            $0.meetingDate <= Date()
            && $0.status != .cancelled
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if members.count <= 1 {
                        invitePromptCard
                    }

                    plannerSection

                    if let meeting = upcomingMeeting {
                        Button {
                            Haptic.light()
                            showMeetingDetail = meeting
                        } label: {
                            meetingCard(meeting)
                        }
                        .buttonStyle(.plain)
                    } else {
                        // 지난 모임 기록 카드
                        if let past = pastMeeting,
                           !dismissedRecordCard,
                           !(appState?.myRecordedMeetingIds.contains(past.id) ?? false) {
                            recordPromptCard(past)
                        }

                        // 모임 추가하기 카드
                        if isPlanner {
                            addMeetingCard
                        } else if upcomingMeeting == nil && pastMeeting == nil {
                            emptyMeetingView
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
            .toast($toast)
            .navigationTitle(family.name)
            .fullScreenCover(item: $showMeetingDetail) { meeting in
                MeetingDetailView(meeting: meeting, onBack: {
                    showMeetingDetail = nil
                }, onDeleted: {
                    showMeetingDetail = nil
                    Task { await appState?.refreshMeetings() }
                }, onUpdated: {
                    Task { await appState?.refreshMeetings() }
                })
                .environment(appState)
            }
            .fullScreenCover(isPresented: $showCreateMeeting) {
                CreateMeetingView(onBack: {
                    showCreateMeeting = false
                }, onCreated: { meeting, poll in
                    showCreateMeeting = false
                    if let appState {
                        Task {
                            do {
                                let created = try await appState.createMeeting(meeting)
                                if let poll {
                                    _ = try await appState.createPoll(meetingId: created.id, poll: poll)
                                }
                            } catch {
                                appState.errorMessage = error.localizedDescription
                            }
                        }
                    }
                })
                .environment(appState)
            }
            .fullScreenCover(item: $showCreateRecord) { meeting in
                CreateRecordView(meeting: meeting, onBack: {
                    showCreateRecord = nil
                }, onSaved: { record in
                    showCreateRecord = nil
                    if let appState {
                        Task {
                            _ = try? await appState.createRecord(meetingId: meeting.id, record: record)
                            toast = ToastData(type: .success, message: "기록이 저장되었습니다")
                        }
                    }
                })
                .environment(appState)
            }
            .fullScreenCover(isPresented: $showInvite) {
                InviteMemberView(onBack: { showInvite = false })
                    .environment(appState)
            }
        }
    }

    // MARK: - 플래너 섹션
    private var plannerSection: some View {
        HStack(spacing: 12) {
            AvatarView(name: currentPlanner?.name ?? "?", imageURL: currentPlanner?.profileImageURL)

            VStack(alignment: .leading, spacing: 2) {
                if isPlanner {
                    Text("이번 주 플래너는 나!")
                        .font(.headline)
                        .foregroundStyle(.primary)
                } else {
                    Text("이번 주 플래너")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(currentPlanner?.name ?? "미정")님")
                        .font(.headline)
                        .foregroundStyle(.primary)
                }
            }

            Spacer()
        }
        .card(highlighted: isPlanner)
    }

    // MARK: - 모임 카드
    private func meetingCard(_ meeting: Meeting) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                BadgeView(
                    text: meeting.status == .confirmed ? "확정" : "계획중",
                    color: meeting.status == .confirmed ? AppColors.secondary : AppColors.warning
                )

                if meeting.hasPoll {
                    BadgeView(text: "투표", color: AppColors.info)
                }

                Spacer()

                Text(dDayText(for: meeting.meetingDate))
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
            }

            VStack(alignment: .leading, spacing: 10) {
                infoRow(icon: "calendar", text: formatDate(meeting.meetingDate))
                infoRow(icon: "mappin.circle.fill", text: meeting.place)
                if let activity = meeting.activity {
                    infoRow(icon: "figure.walk", text: activity)
                }
            }

            HStack(spacing: 6) {
                Image(systemName: "person.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("플래너: \(meeting.plannerName)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .card()
    }

    // MARK: - 모임 기록 유도 카드
    private func recordPromptCard(_ meeting: Meeting) -> some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 16) {
                Image(systemName: "camera.fill")
                .font(.system(size: 32))
                .foregroundStyle(AppColors.primary)

            Text("모임은 어떠셨나요?")
                .font(.headline)
                .foregroundStyle(.primary)

            Text("\(meeting.place)에서의 모임을 기록해보세요")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button(action: {
                Haptic.light()
                showCreateRecord = meeting
            }) {
                Text("기록하기")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(AppColors.primary)
                    .clipShape(Capsule())
            }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)

            Button {
                Haptic.light()
                withAnimation(.spring(duration: 0.25)) {
                    dismissedRecordCard = true
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .frame(width: 32, height: 32)
            }
            .padding(4)
        }
        .card()
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }

    // MARK: - 모임 추가하기 카드
    private var addMeetingCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 36))
                .foregroundStyle(AppColors.primary)

            Text("새 모임을 계획해보세요")
                .font(.headline)
                .foregroundStyle(.primary)

            Button(action: {
                Haptic.medium()
                showCreateMeeting = true
            }) {
                Text("모임 계획하기")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(AppColors.primary)
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .card()
    }

    // MARK: - 빈 상태
    private var emptyMeetingView: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 40))
                .foregroundStyle(AppColors.primary)

            if isPlanner {
                Text("이번 주 모임을 계획해보세요")
                    .font(.headline)
                    .foregroundStyle(.primary)

                Button(action: {
                    Haptic.medium()
                    showCreateMeeting = true
                }) {
                    Text("모임 계획하기")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(AppColors.primary)
                        .clipShape(Capsule())
                }
            } else {
                Text("아직 이번 주 모임이 등록되지 않았어요")
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text("플래너가 모임을 준비 중이에요")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Button(action: {
                    Haptic.light()
                    // TODO: 리마인드 푸시 알림 (Phase 3)
                }) {
                    Text("리마인드 보내기")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(AppColors.warningSubtle)
                        .clipShape(Capsule())
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .card()
    }

    // MARK: - 초대 유도 카드
    private var invitePromptCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.badge.plus")
                .font(.system(size: 32))
                .foregroundStyle(AppColors.primary)

            Text("가족을 초대해보세요!")
                .font(.headline)
                .foregroundStyle(.primary)

            Text("초대 코드를 공유하여 가족 구성원을 추가하세요")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button(action: {
                Haptic.medium()
                showInvite = true
            }) {
                Text("초대하기")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(AppColors.primary)
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .card(highlighted: true)
    }

    // MARK: - Helpers
    private func infoRow(icon: String, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(AppColors.primary)
                .frame(width: 20)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
    }

    private func dDayText(for date: Date) -> String {
        let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: date)).day ?? 0
        if days == 0 { return "D-Day" }
        if days > 0 { return "D-\(days)" }
        return "D+\(abs(days))"
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 (E) a h:mm"
        return formatter.string(from: date)
    }
}

#Preview("모임 있음") {
    HomeView(
        family: MockData.family,
        members: MockData.members,
        meetings: MockData.meetings,
        currentUser: MockData.currentUser
    )
}

#Preview("모임 없음 - 플래너") {
    HomeView(
        family: MockData.family,
        members: MockData.members,
        meetings: [],
        currentUser: MockData.currentUser
    )
}

#Preview("모임 없음 - 비플래너") {
    HomeView(
        family: Family(
            id: "family-001", name: "황씨네", inviteCode: "ABC123",
            inviteCodeExpiresAt: Date(), adminId: "user-002",
            memberCount: 3, currentPlannerIndex: 1, rotationDay: 1, createdAt: Date()
        ),
        members: MockData.members,
        meetings: [],
        currentUser: MockData.currentUser
    )
}

#Preview("구성원 본인만 - 초대 유도") {
    HomeView(
        family: MockData.family,
        members: [MockData.members[0]],
        meetings: [],
        currentUser: MockData.currentUser
    )
}

#Preview("모임 완료 - 기록 유도") {
    HomeView(
        family: MockData.family,
        members: MockData.members,
        meetings: [MockData.meetings[1]],
        currentUser: MockData.currentUser
    )
}
