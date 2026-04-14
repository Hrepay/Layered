import SwiftUI

struct ProfileSetupView: View {
    let onBack: () -> Void
    let onComplete: (String, UIImage?) -> Void
    @State private var name = ""
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?

    var body: some View {
        VStack(spacing: 0) {
            NavBar(
                backAction: onBack,
                trailingText: "완료",
                trailingAction: {
                    Haptic.light()
                    onComplete(name, selectedImage)
                },
                trailingDisabled: name.isEmpty
            )

            Spacer()
                .frame(height: 32)

            Text("프로필 설정")
                .font(.title2)
                .fontWeight(.bold)

            Spacer()
                .frame(height: 32)

            // 프로필 사진
            Button(action: {
                Haptic.light()
                showImagePicker = true
            }) {
                ZStack(alignment: .bottomTrailing) {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    } else {
                        AvatarView(name: name.isEmpty ? " " : name, size: 100)
                    }

                    Image(systemName: "camera.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(AppColors.primary)
                        .clipShape(Circle())
                        .offset(x: 2, y: 2)
                }
            }

            Spacer()
                .frame(height: 32)

            // 이름 입력
            VStack(alignment: .leading, spacing: 8) {
                Text("이름")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                AppTextField(placeholder: "이름을 입력해주세요", text: $name)
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
    }
}

#Preview {
    ProfileSetupView(onBack: {}, onComplete: { _, _ in })
}
