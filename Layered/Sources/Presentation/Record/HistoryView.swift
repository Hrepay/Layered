import SwiftUI

struct HistoryView: View {
    private let meetings = MockData.meetings
    @State private var selectedMeeting: Meeting?

    var body: some View {
        NavigationStack {
            Group {
                if meetings.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()

                        Image(systemName: "clock.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(Color(.systemGray4))

                        Text("첫 번째 가족 모임의 추억을\n남겨보세요")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        Spacer()
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // MARK: - 상단 통계 카드
                            HStack(spacing: 12) {
                                statCard(
                                    icon: "person.3.fill",
                                    value: "\(meetings.count)",
                                    label: "총 모임"
                                )
                                statCard(
                                    icon: "star.fill",
                                    value: "4.5",
                                    label: "평균 별점"
                                )
                                statCard(
                                    icon: "flame.fill",
                                    value: "3주",
                                    label: "연속 달성"
                                )
                            }
                            .padding(.top, 4)

                            // MARK: - 타임라인
                            ForEach(meetings) { meeting in
                                Button {
                                    Haptic.light()
                                    selectedMeeting = meeting
                                } label: {
                                    HStack(alignment: .top, spacing: 14) {
                                        // 날짜 컬럼
                                        VStack(spacing: 2) {
                                            Text(dayText(meeting.meetingDate))
                                                .font(.title3)
                                                .fontWeight(.bold)

                                            Text(monthText(meeting.meetingDate))
                                                .font(.caption2)
                                                .foregroundStyle(.secondary)
                                        }
                                        .frame(width: 44)

                                        // 모임 카드
                                        VStack(alignment: .leading, spacing: 8) {
                                            HStack {
                                                Text(meeting.place)
                                                    .font(.subheadline)
                                                    .fontWeight(.semibold)
                                                    .foregroundStyle(.primary)

                                                Spacer()

                                                BadgeView(
                                                    text: statusText(meeting.status),
                                                    color: statusColor(meeting.status)
                                                )
                                            }

                                            if let activity = meeting.activity {
                                                Text(activity)
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                            }

                                            HStack(spacing: 4) {
                                                Image(systemName: "person.fill")
                                                    .font(.caption2)
                                                Text(meeting.plannerName)
                                                    .font(.caption2)
                                            }
                                            .foregroundStyle(.secondary)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .card()
                                        .tappableCard()
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("히스토리")
            .fullScreenCover(item: $selectedMeeting) { meeting in
                RecordDetailView(meeting: meeting, onBack: { selectedMeeting = nil })
            }
        }
    }

    // MARK: - Stat Card
    private func statCard(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(AppColors.primary)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(AppColors.primary)

            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppColors.primarySubtle)
        )
    }

    // MARK: - Helpers
    private func dayText(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    private func monthText(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월"
        return formatter.string(from: date)
    }

    private func statusText(_ status: Meeting.Status) -> String {
        switch status {
        case .planning: return "계획 중"
        case .confirmed: return "확정"
        case .completed: return "완료"
        case .cancelled: return "취소"
        }
    }

    private func statusColor(_ status: Meeting.Status) -> Color {
        switch status {
        case .planning: return AppColors.info
        case .confirmed: return AppColors.secondary
        case .completed: return AppColors.primary
        case .cancelled: return Color(.systemGray4)
        }
    }
}

#Preview("히스토리 목록") {
    HistoryView()
}
