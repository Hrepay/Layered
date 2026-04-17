import SwiftUI

struct AccountView: View {
    let onBack: () -> Void
    @Environment(AppState.self) private var appState: AppState?

    @State private var showLogoutAlert = false
    @State private var showDeleteAlert = false

    var body: some View {
        VStack(spacing: 0) {
            NavBar(title: "계정 관리", backAction: onBack)

            VStack(spacing: 16) {
                // MARK: - Actions card
                VStack(spacing: 0) {
                    row(
                        icon: "rectangle.portrait.and.arrow.right.fill",
                        iconColor: AppColors.primary,
                        title: "로그아웃"
                    ) {
                        showLogoutAlert = true
                    }

                    Divider().padding(.leading, 66)

                    row(
                        icon: "trash.fill",
                        iconColor: AppColors.primary,
                        title: "계정 삭제"
                    ) {
                        showDeleteAlert = true
                    }
                }
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 20)

                // MARK: - Footer
                Text("계정을 삭제하면 모든 데이터가 영구적으로 삭제되며 복구할 수 없습니다.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 24)
            }
            .padding(.top, 24)

            Spacer()
        }
        .alert("로그아웃", isPresented: $showLogoutAlert) {
            Button("취소", role: .cancel) {}
            Button("로그아웃", role: .destructive) {
                appState?.signOut()
            }
        } message: {
            Text("정말 로그아웃하시겠습니까?")
        }
        .alert("계정 삭제", isPresented: $showDeleteAlert) {
            Button("취소", role: .cancel) {}
            Button("삭제", role: .destructive) {
                Task { await appState?.deleteAccount() }
            }
        } message: {
            Text("모든 데이터가 영구 삭제됩니다.\nApple 재인증이 필요합니다.")
        }
        .swipeBack(onBack: onBack)
    }

    private func row(icon: String, iconColor: Color, title: String, action: @escaping () -> Void) -> some View {
        Button {
            Haptic.light()
            action()
        } label: {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundStyle(iconColor)
                    .frame(width: 36, height: 36)
                    .background(.white)
                    .clipShape(Circle())

                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AccountView(onBack: {})
}
