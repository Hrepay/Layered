import SwiftUI
import MapKit

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
                VStack(alignment: .leading, spacing: 20) {
                    // 상태 뱃지
                    HStack(spacing: 8) {
                        BadgeView(text: statusText, color: statusColor)

                        if meeting.hasPoll {
                            BadgeView(text: "투표 있음", color: AppColors.info)
                        }
                    }

                    // 모임 정보
                    VStack(alignment: .leading, spacing: 14) {
                        infoRow(icon: "calendar", label: "날짜", value: formatDate(meeting.meetingDate))
                        infoRow(icon: "mappin.circle.fill", label: "장소", value: meeting.place)
                        if let activity = meeting.activity {
                            infoRow(icon: "figure.walk", label: "활동", value: activity)
                        }
                        infoRow(icon: "person.fill", label: "플래너", value: meeting.plannerName)
                    }
                    .card()

                    // 지도 미리보기
                    if let lat = meeting.placeLatitude, let lng = meeting.placeLongitude {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("위치")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)

                            Map(initialPosition: .region(MKCoordinateRegion(
                                center: CLLocationCoordinate2D(latitude: lat, longitude: lng),
                                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                            )))
                            .frame(height: 180)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                    }

                    // 투표 섹션
                    if meeting.hasPoll, poll != nil {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("투표")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)

                            Button(action: {
                                Haptic.light()
                                showPoll = true
                            }) {
                                HStack {
                                    Image(systemName: "chart.bar.fill")
                                        .foregroundStyle(AppColors.info)
                                    Text("투표 참여 / 결과 보기")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(.tertiary)
                                }
                                .card()
                            }
                            .tappableCard()
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .task {
            if meeting.hasPoll, let appState {
                let polls = try? await appState.getPolls(meetingId: meeting.id)
                poll = polls?.first
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
                        try? await appState.updateMeeting(updatedMeeting)
                        onUpdated?()
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
                        try? await appState.deleteMeeting(meeting.id)
                        onDeleted?()
                    }
                }
            }
        } message: {
            Text("정말 삭제하시겠습니까?\n관련 기록도 함께 삭제됩니다.")
        }
    }

    private var statusText: String {
        switch meeting.status {
        case .planning: return "계획 중"
        case .confirmed: return "확정"
        case .completed: return "완료"
        case .cancelled: return "취소"
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

    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(AppColors.primary)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
            }
        }
    }

    private func refreshPoll() {
        guard let appState, let currentPoll = poll else { return }
        Task {
            if let updated = try? await appState.getPoll(meetingId: meeting.id, pollId: currentPoll.id) {
                poll = updated
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 (E) a h:mm"
        return formatter.string(from: date)
    }
}

#Preview("확정된 모임") {
    MeetingDetailView(meeting: MockData.meetings[0], onBack: {})
}

#Preview("완료된 모임") {
    MeetingDetailView(meeting: MockData.meetings[1], onBack: {})
}
