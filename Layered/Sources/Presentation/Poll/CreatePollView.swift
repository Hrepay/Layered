import SwiftUI

struct CreatePollView: View {
    let onBack: () -> Void
    let onCreated: (Poll) -> Void

    @State private var question = ""
    @State private var options: [String] = ["", ""]
    @State private var isAnonymous = false

    var body: some View {
        VStack(spacing: 0) {
            NavBar(
                title: "투표 만들기",
                backAction: onBack,
                trailingText: "만들기",
                trailingAction: {
                    Haptic.medium()
                    let pollOptions = options.enumerated().compactMap { index, title -> PollOption? in
                        guard !title.isEmpty else { return nil }
                        return PollOption(
                            id: UUID().uuidString,
                            title: title,
                            description: nil,
                            imageURL: nil,
                            voterIds: [],
                            voteCount: 0
                        )
                    }
                    let poll = Poll(
                        id: UUID().uuidString,
                        question: question,
                        isAnonymous: isAnonymous,
                        allowMultiple: true,
                        options: pollOptions,
                        createdAt: Date()
                    )
                    onCreated(poll)
                },
                trailingDisabled: !isValid
            )

            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - 투표 제목
                    VStack(alignment: .leading, spacing: 8) {
                        Text("투표 제목")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)

                        AppTextField(placeholder: "예: 어디로 갈까요?", text: $question)
                    }

                    // MARK: - 선택지
                    VStack(alignment: .leading, spacing: 12) {
                        Text("선택지")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)

                        ForEach(options.indices, id: \.self) { index in
                            HStack(spacing: 10) {
                                AppTextField(
                                    placeholder: "선택지 \(index + 1)",
                                    text: $options[index]
                                )

                                if options.count > 2 {
                                    Button {
                                        Haptic.light()
                                        _ = withAnimation(.spring(duration: 0.25)) {
                                            options.remove(at: index)
                                        }
                                    } label: {
                                        Image(systemName: "minus.circle.fill")
                                            .font(.title3)
                                            .foregroundStyle(.red)
                                    }
                                }
                            }
                        }

                        if options.count < 4 {
                            Button {
                                Haptic.light()
                                withAnimation(.spring(duration: 0.25)) {
                                    options.append("")
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "plus.circle.fill")
                                    Text("선택지 추가")
                                }
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(AppColors.primary)
                            }
                            .padding(.top, 4)
                        }
                    }

                    // MARK: - 익명 투표
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("익명 투표")
                                .font(.subheadline)
                                .fontWeight(.medium)

                            Text("누가 투표했는지 비공개로 진행돼요")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Toggle("", isOn: $isAnonymous)
                            .labelsHidden()
                            .tint(AppColors.primary)
                    }
                    .card()
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
        }
        .swipeBack(onBack: onBack)
        .dismissKeyboardOnTap()
    }

    private var isValid: Bool {
        !question.isEmpty && options.filter({ !$0.isEmpty }).count >= 2
    }
}

#Preview {
    CreatePollView(onBack: {}, onCreated: { _ in })
}
