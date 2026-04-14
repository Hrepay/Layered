import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState: AppState?

    @State private var showProfileEdit = false
    @State private var showMemberList = false
    @State private var showInvite = false
    @State private var showRotation = false
    @State private var showNotification = false
    @State private var showAccount = false
    @State private var showFamilyManagement = false

    private var userName: String { appState?.currentUser?.name ?? "사용자" }
    private var familyName: String { appState?.currentFamily?.name ?? "" }

    var body: some View {
        NavigationStack {
            List {
                // MARK: - Profile Card
                Section {
                    Button(action: { showProfileEdit = true }) {
                        HStack(spacing: 14) {
                            AvatarView(name: userName, size: 50)

                            VStack(alignment: .leading, spacing: 3) {
                                Text(userName)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Text(familyName)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 6)
                    }
                }

                // MARK: - 가정 관리
                Section("가정 관리") {
                    Button(action: { showMemberList = true }) {
                        settingsRow(icon: "person.3.fill", title: "구성원 목록")
                    }
                    Button(action: { showInvite = true }) {
                        settingsRow(icon: "person.badge.plus.fill", title: "초대하기")
                    }
                    Button(action: { showRotation = true }) {
                        settingsRow(icon: "arrow.triangle.2.circlepath", title: "로테이션 순서")
                    }
                    Button(action: { showFamilyManagement = true }) {
                        settingsRow(icon: "house.fill", title: "가정 관리")
                    }
                }

                // MARK: - 앱 설정
                Section("앱 설정") {
                    Button(action: { showNotification = true }) {
                        settingsRow(icon: "bell.fill", title: "알림 설정")
                    }
                }

                // MARK: - 계정
                Section {
                    Button(action: { showAccount = true }) {
                        settingsRow(icon: "person.crop.circle.fill", title: "계정 관리")
                    }
                }
            }
            .navigationTitle("설정")
            .fullScreenCover(isPresented: $showProfileEdit) {
                ProfileEditView(onBack: { showProfileEdit = false })
                    .environment(appState)
            }
            .fullScreenCover(isPresented: $showMemberList) {
                MemberListView(onBack: { showMemberList = false })
                    .environment(appState)
            }
            .fullScreenCover(isPresented: $showInvite) {
                InviteMemberView(onBack: { showInvite = false })
                    .environment(appState)
            }
            .fullScreenCover(isPresented: $showRotation) {
                RotationOrderView(onBack: { showRotation = false })
                    .environment(appState)
            }
            .fullScreenCover(isPresented: $showNotification) {
                NotificationSettingsView(onBack: { showNotification = false })
            }
            .fullScreenCover(isPresented: $showAccount) {
                AccountView(onBack: { showAccount = false })
                    .environment(appState)
            }
            .fullScreenCover(isPresented: $showFamilyManagement) {
                FamilyManagementView(onBack: { showFamilyManagement = false })
                    .environment(appState)
            }
        }
    }

    private func settingsRow(icon: String, title: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(AppColors.primary)
                .frame(width: 24, height: 24, alignment: .center)
            Text(title)
                .foregroundStyle(.primary)
        }
    }
}

#Preview {
    SettingsView()
}
