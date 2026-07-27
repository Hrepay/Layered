import SwiftUI

/// 모임 생성·수정 공용 날짜 섹션.
/// 당일 모임은 기존 그래피컬 피커(날짜+시각), 여행은 시작일~종료일 기간 선택으로 전환.
struct MeetingDateSection: View {
    @Binding var isTrip: Bool
    @Binding var date: Date
    @Binding var endDate: Date
    /// 생성 화면은 과거 선택 불가, 수정 화면은 허용(지난 모임 날짜 보정용).
    var allowsPastDates: Bool

    private var calendar: Calendar { Calendar.current }

    /// 여행 종료일 하한 — 최소 1박 보장.
    private var minEndDate: Date {
        calendar.date(byAdding: .day, value: 1, to: date) ?? date
    }

    private var nightsText: String {
        let nights = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: date),
            to: calendar.startOfDay(for: endDate)
        ).day ?? 1
        return "\(nights)박 \(nights + 1)일"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle(isOn: $isTrip) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("1박 이상 여행이에요")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                    Text("시작일과 종료일로 기간을 정해요")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .tint(AppColors.primary)
            .padding(14)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))

            if isTrip {
                VStack(spacing: 4) {
                    if allowsPastDates {
                        DatePicker("시작일", selection: $date, displayedComponents: [.date])
                    } else {
                        DatePicker("시작일", selection: $date, in: Date()..., displayedComponents: [.date])
                    }
                    Divider()
                    DatePicker("종료일", selection: $endDate, in: minEndDate..., displayedComponents: [.date])
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .tint(AppColors.primary)
                .padding(14)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))

                HStack(spacing: 6) {
                    Image(systemName: "moon.stars.fill")
                        .font(.caption)
                        .foregroundStyle(AppColors.info)
                    Text(nightsText)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }
                .padding(.leading, 2)
            } else {
                if allowsPastDates {
                    DatePicker("", selection: $date, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.graphical)
                        .tint(AppColors.primary)
                        .labelsHidden()
                } else {
                    DatePicker("", selection: $date, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.graphical)
                        .tint(AppColors.primary)
                        .labelsHidden()
                }
            }
        }
        .onChange(of: isTrip) { _, on in
            if on, endDate < minEndDate {
                endDate = minEndDate
            }
        }
        .onChange(of: date) { _, _ in
            if isTrip, endDate < minEndDate {
                endDate = minEndDate
            }
        }
    }
}

#Preview {
    @Previewable @State var isTrip = true
    @Previewable @State var date = Date()
    @Previewable @State var endDate = Calendar.current.date(byAdding: .day, value: 2, to: Date())!
    return ScrollView {
        MeetingDateSection(isTrip: $isTrip, date: $date, endDate: $endDate, allowsPastDates: false)
            .padding(20)
    }
}
