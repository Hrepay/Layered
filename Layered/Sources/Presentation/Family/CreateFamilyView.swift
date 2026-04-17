import SwiftUI

struct CreateFamilyView: View {
    let onBack: () -> Void
    let onCreated: (String) -> Void
    @State private var familyName = ""

    var body: some View {
        VStack(spacing: 0) {
            NavBar(
                backAction: onBack,
                trailingText: "다음",
                trailingAction: {
                    Haptic.light()
                    onCreated(familyName)
                },
                trailingDisabled: familyName.isEmpty
            )

            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "house.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(AppColors.primary)

                Text("가정 만들기")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("가족이 함께 사용할 가정 이름을 입력해주세요")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
                .frame(height: 40)

            AppTextField(placeholder: "가정 이름 (예: 황씨네)", text: $familyName)
                .padding(.horizontal, 24)

            Spacer()
        }
        .swipeBack(onBack: onBack)
    }
}

#Preview {
    CreateFamilyView(onBack: {}, onCreated: { _ in })
}
