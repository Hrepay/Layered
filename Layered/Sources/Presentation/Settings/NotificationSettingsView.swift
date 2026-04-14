import SwiftUI

struct NotificationSettingsView: View {
    let onBack: () -> Void
    @State private var pushEnabled = true
    @State private var plannerReminder = true
    @State private var meetingCreated = true
    @State private var pollCreated = true

    var body: some View {
        VStack(spacing: 0) {
            NavBar(title: "알림 설정", backAction: onBack)

            List {
                Section {
                    Toggle("푸시 알림", isOn: $pushEnabled)
                        .tint(AppColors.primary)
                }

                Section("알림 종류") {
                    Toggle("플래너 리마인드", isOn: $plannerReminder)
                        .tint(AppColors.primary)
                    Toggle("모임 등록", isOn: $meetingCreated)
                        .tint(AppColors.primary)
                    Toggle("투표 등록", isOn: $pollCreated)
                        .tint(AppColors.primary)
                }
                .disabled(!pushEnabled)
            }
            .listStyle(.insetGrouped)
        }
    }
}

#Preview {
    NotificationSettingsView(onBack: {})
}
