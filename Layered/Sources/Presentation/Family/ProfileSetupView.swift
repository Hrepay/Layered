import SwiftUI

struct ProfileSetupView: View {
    let onBack: () -> Void
    let onComplete: (String) -> Void
    @State private var name = ""
    @State private var showImagePicker = false

    var body: some View {
        VStack(spacing: 0) {
            NavBar(
                backAction: onBack,
                trailingText: "완료",
                trailingAction: {
                    Haptic.light()
                    onComplete(name)
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
                    AvatarView(name: name.isEmpty ? " " : name, size: 100)

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
    }
}

#Preview {
    ProfileSetupView(onBack: {}, onComplete: { _ in })
}
