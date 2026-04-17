import SwiftUI
import MapKit
import LinkPresentation

struct MeetingDetailView: View {
    @State private var meeting: Meeting
    let onBack: () -> Void
    var onDeleted: (() -> Void)?
    var onUpdated: (() -> Void)?

    @Environment(AppState.self) private var appState: AppState?

    @State private var showDeleteAlert = false
    @State private var showEdit = false
    @State private var showPoll = false
    @State private var poll: Poll?
    @State private var linkMetadata: LPLinkMetadata?

    init(meeting: Meeting, onBack: @escaping () -> Void, onDeleted: (() -> Void)? = nil, onUpdated: (() -> Void)? = nil) {
        _meeting = State(initialValue: meeting)
        self.onBack = onBack
        self.onDeleted = onDeleted
        self.onUpdated = onUpdated
    }

    var body: some View {
        VStack(spacing: 0) {
            NavBar(
                title: "모임 상세",
                backAction: onBack,
                trailingMenu: AnyView(
                    Menu {
                        Button("수정", systemImage: "pencil") { showEdit = true }
                        Button("삭제", systemImage: "trash", role: .destructive) {
                            showDeleteAlert = true
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title3)
                            .foregroundStyle(.primary)
                    }
                )
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // MARK: - 상단 헤더
                    VStack(alignment: .leading, spacing: 8) {
                        BadgeView(text: statusText, color: statusColor)

                        Text(meeting.place)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)

                        Text("함께 모여 따뜻한 시간을 보냅니다.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    // MARK: - 일시 카드
                    HStack(spacing: 14) {
                        Image(systemName: "calendar")
                            .font(.title3)
                            .foregroundStyle(AppColors.primary)
                            .frame(width: 44, height: 44)
                            .background(.white)
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 2) {
                            Text("일시")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(formatDateFull(meeting.meetingDate))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text(formatTimePeriod(meeting.meetingDate))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(formatTime(meeting.meetingDate))
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                        }
                    }
                    .card()

                    // MARK: - 장소 카드
                    HStack(spacing: 14) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title3)
                            .foregroundStyle(AppColors.primary)
                            .frame(width: 44, height: 44)
                            .background(.white)
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 2) {
                            Text("장소")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(meeting.place)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                        }

                        Spacer()
                    }
                    .card()

                    // MARK: - 활동 & 플래너 (2열 그리드)
                    HStack(spacing: 12) {
                        // 활동
                        VStack(alignment: .leading, spacing: 10) {
                            Image(systemName: activityIconName)
                                .font(.title3)
                                .foregroundStyle(AppColors.primary)
                                .frame(width: 40, height: 40)
                                .background(.white)
                                .clipShape(Circle())

                            Text("활동")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(meeting.activity ?? "미정")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                                .lineLimit(3)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .card()

                        // 플래너
                        VStack(alignment: .leading, spacing: 10) {
                            Image(systemName: "person.fill")
                                .font(.title3)
                                .foregroundStyle(AppColors.primary)
                                .frame(width: 40, height: 40)
                                .background(.white)
                                .clipShape(Circle())

                            Text("작성자")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(meeting.plannerName)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .card()
                    }

                    // MARK: - 참여 인원
                    if let members = appState?.members, !members.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("참여 인원 (\(members.count)명)")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.primary)
                                Spacer()
                            }

                            HStack(spacing: -8) {
                                ForEach(members.prefix(5)) { member in
                                    AvatarView(name: member.name, size: 36, imageURL: member.profileImageURL)
                                        .overlay(Circle().stroke(.white, lineWidth: 2))
                                }
                                if members.count > 5 {
                                    Text("+\(members.count - 5)")
                                        .font(.caption2)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.secondary)
                                        .frame(width: 36, height: 36)
                                        .background(Color(.tertiarySystemFill))
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(.white, lineWidth: 2))
                                }
                            }
                        }
                        .card()
                    }

                    // MARK: - 장소 링크 미리보기
                    if let urlString = meeting.placeURL, let url = URL(string: urlString) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("장소 링크")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)

                            if let metadata = linkMetadata {
                                LinkPreviewCard(metadata: metadata)
                            } else {
                                Button {
                                    Haptic.light()
                                    UIApplication.shared.open(url)
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "link")
                                            .foregroundStyle(AppColors.info)
                                        Text(urlString)
                                            .font(.caption)
                                            .foregroundStyle(.primary)
                                            .lineLimit(1)
                                        Spacer()
                                        Image(systemName: "arrow.up.right")
                                            .font(.caption)
                                            .foregroundStyle(.tertiary)
                                    }
                                    .card()
                                }
                            }
                        }
                    }

                    // MARK: - 지도
                    if let lat = meeting.placeLatitude, let lng = meeting.placeLongitude {
                        Map(initialPosition: .region(MKCoordinateRegion(
                            center: CLLocationCoordinate2D(latitude: lat, longitude: lng),
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        ))) {
                            Marker(meeting.place, coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng))
                                .tint(AppColors.primary)
                        }
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }

                    // MARK: - 하단 투표 버튼
                    if meeting.hasPoll, poll != nil {
                        Button(action: {
                            Haptic.medium()
                            showPoll = true
                        }) {
                            HStack {
                                Image(systemName: "chart.bar.fill")
                                    .font(.body)
                                Text("투표 참여 / 결과 보기")
                                    .fontWeight(.semibold)
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AppColors.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
        }
        .task {
            if meeting.hasPoll, let appState {
                let polls = try? await appState.getPolls(meetingId: meeting.id)
                poll = polls?.first
            }
            if let urlString = meeting.placeURL, let url = URL(string: urlString) {
                let provider = LPMetadataProvider()
                if let metadata = try? await provider.startFetchingMetadata(for: url) {
                    linkMetadata = metadata
                }
            }
        }
        .fullScreenCover(isPresented: $showEdit) {
            EditMeetingView(meeting: meeting, onBack: {
                showEdit = false
            }, onSaved: { updatedMeeting in
                showEdit = false
                meeting = updatedMeeting
                if let appState {
                    Task {
                        do {
                            try await appState.updateMeeting(updatedMeeting)
                            onUpdated?()
                        } catch {
                            appState.error = AppError.from(error)
                        }
                    }
                }
            })
        }
        .fullScreenCover(isPresented: $showPoll) {
            if let poll {
                PollVoteView(poll: poll, onBack: {
                    showPoll = false
                    refreshPoll()
                }, meetingId: meeting.id)
                    .environment(appState)
            }
        }
        .alert("모임 삭제", isPresented: $showDeleteAlert) {
            Button("취소", role: .cancel) {}
            Button("삭제", role: .destructive) {
                if let appState {
                    Task {
                        do {
                            try await appState.deleteMeeting(meeting.id)
                            onDeleted?()
                        } catch {
                            appState.error = AppError.from(error)
                        }
                    }
                }
            }
        } message: {
            Text("정말 삭제하시겠습니까?\n관련 기록도 함께 삭제됩니다.")
        }
        .swipeBack(onBack: onBack)
    }

    // MARK: - Computed

    private var statusText: String {
        switch meeting.status {
        case .planning: return "예정된 모임"
        case .confirmed: return "확정된 모임"
        case .completed: return "완료된 모임"
        case .cancelled: return "취소된 모임"
        }
    }

    private var statusColor: Color {
        switch meeting.status {
        case .planning: return AppColors.warning
        case .confirmed: return AppColors.secondary
        case .completed: return Color.gray
        case .cancelled: return Color.red
        }
    }

    private var activityIconName: String {
        guard let activity = meeting.activity else { return "figure.walk" }
        let iconMap: [(String, String)] = [
            ("외식", "fork.knife"),
            ("카페", "cup.and.saucer.fill"),
            ("영화", "film.fill"),
            ("산책", "figure.walk"),
            ("운동", "figure.run"),
            ("피크닉", "leaf.fill"),
            ("쇼핑", "cart.fill"),
            ("집에서", "house.fill"),
            ("게임", "gamecontroller.fill"),
            ("문화생활", "book.fill"),
        ]
        for (keyword, icon) in iconMap {
            if activity.contains(keyword) { return icon }
        }
        return "figure.walk"
    }

    // MARK: - Helpers

    private func refreshPoll() {
        guard let appState, let currentPoll = poll else { return }
        Task {
            if let updated = try? await appState.getPoll(meetingId: meeting.id, pollId: currentPoll.id) {
                poll = updated
            }
        }
    }

    private func formatDateFull(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일 (E)"
        return formatter.string(from: date)
    }

    private func formatTimePeriod(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "a"
        return formatter.string(from: date)
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "h:mm"
        return formatter.string(from: date)
    }
}

#Preview("확정된 모임") {
    MeetingDetailView(meeting: MockData.meetings[0], onBack: {})
}

#Preview("완료된 모임") {
    MeetingDetailView(meeting: MockData.meetings[1], onBack: {})
}
