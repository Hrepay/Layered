import SwiftUI

struct CreateMeetingView: View {
    let onBack: () -> Void
    let onCreated: (Meeting) -> Void

    @State private var date = Date()
    @State private var place = ""
    @State private var activity = ""
    @State private var showPollCreation = false
    @State private var hasPoll = false

    var body: some View {
        VStack(spacing: 0) {
            NavBar(
                title: "모임 계획하기",
                backAction: onBack,
                trailingText: "등록",
                trailingAction: {
                    Haptic.medium()
                    onCreated(MockData.meetings[0])
                },
                trailingDisabled: place.isEmpty
            )

            ScrollView {
                VStack(spacing: 24) {
                    // 날짜 & 시간
                    VStack(alignment: .leading, spacing: 8) {
                        Text("날짜 & 시간")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)

                        DatePicker("", selection: $date, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.graphical)
                            .tint(AppColors.primary)
                            .labelsHidden()
                    }

                    // 장소
                    VStack(alignment: .leading, spacing: 8) {
                        Text("장소")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)

                        AppTextField(placeholder: "장소를 입력해주세요", text: $place)
                    }

                    // 활동 내용
                    VStack(alignment: .leading, spacing: 8) {
                        Text("활동 내용 (선택)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)

                        AppTextField(placeholder: "어떤 활동을 할까요?", text: $activity)
                    }

                    // 투표 추가
                    if hasPoll {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(AppColors.secondary)
                            Text("투표가 추가되었습니다")
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                            Spacer()
                            Button("삭제") { hasPoll = false }
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                        .card()
                    } else {
                        Button(action: { showPollCreation = true }) {
                            HStack {
                                Image(systemName: "chart.bar.fill")
                                    .foregroundStyle(AppColors.info)
                                Text("투표 추가")
                                    .foregroundStyle(.primary)
                            }
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppColors.infoSubtle)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .fullScreenCover(isPresented: $showPollCreation) {
            CreatePollView(onBack: {
                showPollCreation = false
            }, onCreated: { _ in
                hasPoll = true
                showPollCreation = false
            })
        }
    }
}

#Preview {
    CreateMeetingView(onBack: {}, onCreated: { _ in })
}
