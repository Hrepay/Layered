import SwiftUI

struct CreateMeetingView: View {
    let onBack: () -> Void
    let onCreated: (Meeting, Poll?) -> Void
    @Environment(AppState.self) private var appState: AppState?

    @State private var date = Date()
    @State private var place = ""
    @State private var activity = ""
    @State private var showPollCreation = false
    @State private var hasPoll = false
    @State private var createdPoll: Poll?

    var body: some View {
        VStack(spacing: 0) {
            NavBar(
                title: "모임 계획하기",
                backAction: onBack,
                trailingText: "등록",
                trailingAction: {
                    Haptic.medium()
                    let meeting = Meeting(
                        id: UUID().uuidString,
                        plannerId: appState?.currentUser?.id ?? "",
                        plannerName: appState?.currentUser?.name ?? "",
                        meetingDate: date,
                        place: place,
                        placeLatitude: nil,
                        placeLongitude: nil,
                        activity: activity.isEmpty ? nil : activity,
                        status: .planning,
                        hasPoll: hasPoll,
                        createdAt: Date(),
                        updatedAt: Date()
                    )
                    onCreated(meeting, createdPoll)
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
            }, onCreated: { poll in
                createdPoll = poll
                hasPoll = true
                showPollCreation = false
            })
            .environment(appState)
        }
    }
}

#Preview {
    CreateMeetingView(onBack: {}, onCreated: { _, _ in })
}
