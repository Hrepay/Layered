import SwiftUI

struct ProfileEditView: View {
    let onBack: () -> Void
    @Environment(AppState.self) private var appState: AppState?

    @State private var name = ""
    @State private var showImagePicker = false

    var body: some View {
        VStack(spacing: 0) {
            NavBar(
                title: "프로필 수정",
                backAction: onBack,
                trailingText: "저장",
                trailingAction: {
                    Haptic.medium()
                    if let appState {
                        Task {
                            try? await appState.updateProfile(name: name, profileImageURL: appState.currentUser?.profileImageURL)
                            onBack()
                        }
                    } else {
                        onBack()
                    }
                },
                trailingDisabled: name.isEmpty
            )

            VStack(spacing: 28) {
                // MARK: - Avatar with camera overlay
                Button(action: { showImagePicker = true }) {
                    ZStack(alignment: .bottomTrailing) {
                        AvatarView(name: name.isEmpty ? " " : name, size: 100)

                        Circle()
                            .fill(AppColors.primary)
                            .frame(width: 32, height: 32)
                            .overlay {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.white)
                            }
                            .offset(x: 2, y: 2)
                    }
                }
                .padding(.top, 24)

                // MARK: - Name field
                VStack(alignment: .leading, spacing: 8) {
                    Text("이름")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    AppTextField(placeholder: "이름을 입력해주세요", text: $name)
                }
                .padding(.horizontal, 20)
            }

            Spacer()
        }
        .onAppear {
            name = appState?.currentUser?.name ?? ""
        }
    }
}

#Preview {
    ProfileEditView(onBack: {})
}
