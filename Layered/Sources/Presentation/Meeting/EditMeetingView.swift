import SwiftUI

struct EditMeetingView: View {
    let meeting: Meeting
    let onBack: () -> Void
    let onSaved: (Meeting) -> Void

    @State private var date: Date
    @State private var place: String
    @State private var activity: String

    init(meeting: Meeting, onBack: @escaping () -> Void, onSaved: @escaping (Meeting) -> Void) {
        self.meeting = meeting
        self.onBack = onBack
        self.onSaved = onSaved
        _date = State(initialValue: meeting.meetingDate)
        _place = State(initialValue: meeting.place)
        _activity = State(initialValue: meeting.activity ?? "")
    }

    var body: some View {
        VStack(spacing: 0) {
            // 상단 바: 취소 / 모임 수정 / 저장
            HStack {
                Button("취소") { onBack() }
                    .font(.body)
                    .foregroundStyle(.primary)

                Spacer()

                Text("모임 수정")
                    .font(.headline)

                Spacer()

                Button(action: {
                    Haptic.medium()
                    onSaved(meeting)
                }) {
                    Text("저장")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(place.isEmpty ? .secondary : AppColors.primary)
                }
                .disabled(place.isEmpty)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)

            ScrollView {
                VStack(spacing: 24) {
                    // 날짜 & 시간
                    VStack(alignment: .leading, spacing: 8) {
                        Text("날짜 & 시간")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)

                        DatePicker("", selection: $date, displayedComponents: [.date, .hourAndMinute])
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
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
    }
}

#Preview {
    EditMeetingView(meeting: MockData.meetings[0], onBack: {}, onSaved: { _ in })
}
