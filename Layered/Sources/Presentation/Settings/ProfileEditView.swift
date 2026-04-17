import SwiftUI

struct ProfileEditView: View {
    let onBack: () -> Void
    @Environment(AppState.self) private var appState: AppState

    @State private var name = ""
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var isUploading = false

    var body: some View {
        VStack(spacing: 0) {
            NavBar(
                title: "프로필 수정",
                backAction: onBack,
                trailingText: "완료",
                trailingAction: {
                    Haptic.medium()
                    
                    isUploading = true
                    Task {
                        do {
                            if let image = selectedImage {
                                try await appState.uploadProfileImage(image)
                            }
                            try await appState.updateProfile(name: name, profileImageURL: appState.currentUser?.profileImageURL)
                            isUploading = false
                            onBack()
                        } catch {
                            isUploading = false
                            appState.error = AppError.from(error)
                        }
                    }
                },
                trailingDisabled: name.isEmpty || isUploading
            )

            VStack(spacing: 28) {
                // MARK: - Avatar with camera overlay
                Button(action: { showImagePicker = true }) {
                    ZStack(alignment: .bottomTrailing) {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } else {
                            AvatarView(
                                name: name.isEmpty ? " " : name,
                                size: 100,
                                imageURL: appState.currentUser?.profileImageURL
                            )
                        }

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
        .loadingOverlay(isUploading)
        .onAppear {
            name = appState.currentUser?.name ?? ""
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
    }
}

#Preview {
    ProfileEditView(onBack: {})
}
