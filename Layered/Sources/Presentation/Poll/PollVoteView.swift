import SwiftUI

struct PollVoteView: View {
    let poll: Poll
    let onBack: () -> Void

    @State private var selectedOptions: Set<String> = []
    @State private var hasVoted = false
    @State private var showDeleteAlert = false

    var body: some View {
        VStack(spacing: 0) {
            NavBar(
                title: "투표",
                backAction: onBack,
                trailingMenu: AnyView(
                    Menu {
                        Button("투표 삭제", systemImage: "trash.fill", role: .destructive) {
                            showDeleteAlert = true
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                )
            )

            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - 질문
                    Text(poll.question)
                        .font(.title3)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // MARK: - 남은 시간 + 익명 뱃지
                    HStack(spacing: 10) {
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.caption)
                            Text(remainingText)
                                .font(.caption)
                        }
                        .foregroundStyle(AppColors.secondary)

                        if poll.isAnonymous {
                            BadgeView(text: "익명 투표", color: AppColors.info)
                        }

                        Spacer()
                    }

                    // MARK: - 선택지
                    ForEach(poll.options) { option in
                        let isSelected = selectedOptions.contains(option.id)

                        Button {
                            Haptic.light()
                            withAnimation(.spring(duration: 0.2)) {
                                if isSelected {
                                    selectedOptions.remove(option.id)
                                } else {
                                    if !poll.allowMultiple {
                                        selectedOptions.removeAll()
                                    }
                                    selectedOptions.insert(option.id)
                                }
                            }
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                    .font(.title3)
                                    .foregroundStyle(isSelected ? AppColors.primary : Color(.systemGray3))
                                    .animation(.spring(duration: 0.2), value: isSelected)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(option.title)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.primary)

                                    if let desc = option.description {
                                        Text(desc)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }

                                Spacer()

                                if hasVoted {
                                    Text("\(option.voteCount)표")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(isSelected ? AppColors.primarySubtle : Color(.secondarySystemBackground))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(isSelected ? AppColors.primary : .clear, lineWidth: 1.5)
                            )
                        }
                        .scaleEffect(isSelected ? 1 : 1)
                    }

                    // MARK: - 참여 현황
                    if hasVoted {
                        HStack(spacing: 4) {
                            Image(systemName: "person.2.fill")
                                .font(.caption)
                            Text("\(poll.options.reduce(0) { $0 + $1.voteCount })명 참여")
                                .font(.caption)
                        }
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 100)
            }

            // MARK: - 투표 버튼
            Button {
                Haptic.medium()
                withAnimation { hasVoted = true }
            } label: {
                Text(hasVoted ? "투표 변경" : "투표하기")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        Capsule()
                            .fill(selectedOptions.isEmpty ? Color(.systemGray4) : AppColors.primary)
                    )
            }
            .disabled(selectedOptions.isEmpty)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .alert("투표 삭제", isPresented: $showDeleteAlert) {
            Button("취소", role: .cancel) {}
            Button("삭제", role: .destructive) { onBack() }
        } message: {
            Text("이 투표를 삭제하시겠습니까?\n삭제하면 되돌릴 수 없어요.")
        }
    }

    private var remainingText: String {
        let remaining = poll.deadline.timeIntervalSince(Date())
        if remaining <= 0 { return "마감됨" }
        let hours = Int(remaining) / 3600
        if hours >= 24 {
            return "\(hours / 24)일 \(hours % 24)시간 남음"
        }
        return "\(hours)시간 남음"
    }
}

#Preview("진행 중인 투표") {
    PollVoteView(poll: MockData.poll, onBack: {})
}
