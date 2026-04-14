import SwiftUI

struct RecordDetailView: View {
    let meeting: Meeting
    let onBack: () -> Void
    private let records = MockData.records

    var body: some View {
        VStack(spacing: 0) {
            NavBar(
                title: "모임 기록",
                backAction: onBack
            )

            ScrollView {
                VStack(spacing: 16) {
                    // MARK: - 모임 요약 카드
                    HStack(spacing: 12) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title2)
                            .foregroundStyle(AppColors.primary)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(meeting.place)
                                .font(.headline)

                            Text(formatDate(meeting.meetingDate))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()
                    }
                    .card()

                    // MARK: - 구성원별 기록
                    ForEach(records) { record in
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 10) {
                                AvatarView(name: record.memberName, size: 36)

                                Text(record.memberName)
                                    .font(.subheadline)
                                    .fontWeight(.medium)

                                Spacer()

                                HStack(spacing: 2) {
                                    ForEach(1...5, id: \.self) { star in
                                        Image(systemName: star <= record.rating ? "star.fill" : "star")
                                            .font(.caption2)
                                            .foregroundStyle(star <= record.rating ? AppColors.warning : Color(.systemGray4))
                                    }
                                }

                                // 본인 기록 수정/삭제
                                if record.memberId == MockData.currentUser.id {
                                    Menu {
                                        Button("수정", systemImage: "pencil") {}
                                        Button("삭제", systemImage: "trash.fill", role: .destructive) {}
                                    } label: {
                                        Image(systemName: "ellipsis")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .frame(width: 28, height: 28)
                                    }
                                }
                            }

                            Text(record.comment)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .card()
                    }

                    // MARK: - 미작성 구성원
                    HStack(spacing: 10) {
                        AvatarView(name: "아빠", size: 36)

                        Text("아빠")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        Spacer()

                        BadgeView(text: "미작성", color: Color(.systemGray4))
                    }
                    .card()
                    .opacity(0.4)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 (E)"
        return formatter.string(from: date)
    }
}

#Preview("모임 기록 상세") {
    RecordDetailView(meeting: MockData.meetings[1], onBack: {})
}
