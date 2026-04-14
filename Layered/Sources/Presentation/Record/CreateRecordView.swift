import SwiftUI

struct CreateRecordView: View {
    let meeting: Meeting
    let onBack: () -> Void
    let onSaved: (MeetingRecord) -> Void

    @State private var comment = ""
    @State private var rating = 0
    @State private var photos: [String] = []
    @State private var animatedStar: Int? = nil

    var body: some View {
        VStack(spacing: 0) {
            NavBar(
                title: "모임 기록",
                backAction: onBack,
                trailingText: "저장",
                trailingAction: {
                    Haptic.medium()
                    onSaved(MockData.records[0])
                },
                trailingDisabled: !isValid
            )

            ScrollView {
                VStack(spacing: 24) {
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

                    // MARK: - 사진 첨부
                    VStack(alignment: .leading, spacing: 10) {
                        Text("사진 (최대 3장)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 12) {
                            ForEach(0..<3, id: \.self) { index in
                                if index < photos.count {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(AppColors.primarySubtle)
                                        .aspectRatio(1, contentMode: .fit)
                                        .overlay {
                                            Image(systemName: "photo.fill")
                                                .foregroundStyle(AppColors.primary)
                                        }
                                } else if index == photos.count {
                                    Button {
                                        Haptic.light()
                                        if photos.count < 3 {
                                            photos.append("photo-\(index)")
                                        }
                                    } label: {
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(
                                                style: StrokeStyle(lineWidth: 1.5, dash: [6])
                                            )
                                            .foregroundStyle(Color(.systemGray3))
                                            .aspectRatio(1, contentMode: .fit)
                                            .overlay {
                                                Image(systemName: "plus")
                                                    .font(.title3)
                                                    .foregroundStyle(.secondary)
                                            }
                                    }
                                } else {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemGray6))
                                        .aspectRatio(1, contentMode: .fit)
                                }
                            }
                        }
                    }

                    // MARK: - 별점
                    VStack(alignment: .leading, spacing: 10) {
                        Text("별점")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 10) {
                            ForEach(1...5, id: \.self) { star in
                                Button {
                                    Haptic.light()
                                    withAnimation(.spring(duration: 0.3, bounce: 0.5)) {
                                        rating = star
                                        animatedStar = star
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        animatedStar = nil
                                    }
                                } label: {
                                    Image(systemName: star <= rating ? "star.fill" : "star")
                                        .font(.title2)
                                        .foregroundStyle(star <= rating ? AppColors.warning : Color(.systemGray4))
                                        .scaleEffect(animatedStar == star ? 1.3 : 1.0)
                                        .animation(.spring(duration: 0.3, bounce: 0.5), value: animatedStar)
                                }
                            }

                            Spacer()
                        }
                    }

                    // MARK: - 한 줄 소감
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("한 줄 소감")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)

                            Spacer()

                            Text("\(comment.count)/1000")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }

                        TextEditor(text: $comment)
                            .frame(minHeight: 120)
                            .padding(12)
                            .scrollContentBackground(.hidden)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .onChange(of: comment) { _, newValue in
                                if newValue.count > 1000 {
                                    comment = String(newValue.prefix(1000))
                                }
                            }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
        }
    }

    private var isValid: Bool {
        rating > 0 && !comment.isEmpty
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 (E)"
        return formatter.string(from: date)
    }
}

#Preview("기록 작성") {
    CreateRecordView(meeting: MockData.meetings[1], onBack: {}, onSaved: { _ in })
}
