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
                    Button(action: { showLogoutAlert = true }) {
                        HStack(spacing: 12) {
                            Image(systemName: "rectangle.portrait.and.arrow.right.fill")
                                .foregroundStyle(.red)
                                .frame(width: 24, height: 24)
                            Text("로그아웃")
                                .foregroundStyle(.red)
                            Spacer()
                        }
                        .padding(.vertical, 14)
                    }

                    Divider()

                    Button(action: { showDeleteAlert = true }) {
                        HStack(spacing: 12) {
                            Image(systemName: "trash.fill")
                                .foregroundStyle(.red)
                                .frame(width: 24, height: 24)
                            Text("계정 삭제")
                                .foregroundStyle(.red)
                            Spacer()
                        }
                        .padding(.vertical, 14)
                    }
                }
                .card()
                .padding(.horizontal, 20)

                // MARK: - Footer
                Text("계정을 삭제하면 모든 데이터가 영구적으로 삭제되며 복구할 수 없습니다.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 24)
            }
            .padding(.top, 16)

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
    }
}

#Preview {
    AccountView(onBack: {})
}
