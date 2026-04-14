import SwiftUI

struct PollResultView: View {
    let poll: Poll
    let onBack: () -> Void

    private var totalVotes: Int {
        poll.options.reduce(0) { $0 + $1.voteCount }
    }

    private var maxVotes: Int {
        poll.options.map(\.voteCount).max() ?? 0
    }

    var body: some View {
        VStack(spacing: 0) {
            NavBar(
                title: "투표 결과",
                backAction: onBack
            )

            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - 질문
                    Text(poll.question)
                        .font(.title3)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // MARK: - 확정 뱃지 + 참여 수
                    HStack(spacing: 10) {
                        BadgeView(text: "확정", color: AppColors.secondary)

                        Text("\(totalVotes)명 참여")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Spacer()
                    }

                    // MARK: - 결과 바 그래프
                    ForEach(poll.options) { option in
                        let isWinner = option.voteCount == maxVotes && maxVotes > 0

                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(option.title)
                                    .font(.subheadline)
                                    .fontWeight(isWinner ? .bold : .regular)

                                Spacer()

                                Text("\(option.voteCount)표")
                                    .font(.subheadline)
                                    .fontWeight(isWinner ? .bold : .regular)
                                    .foregroundStyle(isWinner ? .primary : .secondary)
                            }

                            // Bar
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color(.systemGray5))
                                        .frame(height: 10)

                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(isWinner ? AppColors.primary : Color(.systemGray3))
                                        .frame(
                                            width: totalVotes > 0
                                                ? geo.size.width * CGFloat(option.voteCount) / CGFloat(totalVotes)
                                                : 0,
                                            height: 10
                                        )
                                }
                            }
                            .frame(height: 10)

                            // 공개 투표: 투표자 표시
                            if !poll.isAnonymous && !option.voterIds.isEmpty {
                                Text(option.voterIds.joined(separator: ", "))
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .card(highlighted: isWinner)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview("투표 결과") {
    PollResultView(poll: MockData.poll, onBack: {})
}
