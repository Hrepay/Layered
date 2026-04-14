import SwiftUI

struct JoinFamilyView: View {
    let onBack: () -> Void
    let onJoined: (Family) -> Void
    @State private var code = ""
    @State private var showPreview = false
    @State private var showInvalidCodeAlert = false

    var body: some View {
        VStack(spacing: 0) {
            NavBar(
                backAction: onBack,
                trailingText: showPreview ? "참여하기" : "확인",
                trailingAction: {
                    Haptic.light()
                    if showPreview {
                        onJoined(MockData.family)
                    } else {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showPreview = true
                        }
                    }
                },
                trailingDisabled: code.isEmpty
            )

            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 48))
                    .foregroundStyle(AppColors.primary)

                Text("초대 코드 입력")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("가족에게 받은 초대 코드를 입력해주세요")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
                .frame(height: 32)

            TextField("초대 코드 입력", text: $code)
                .font(.system(size: 24, weight: .medium, design: .monospaced))
                .multilineTextAlignment(.center)
                .padding(16)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .textInputAutocapitalization(.characters)
                .padding(.horizontal, 24)

            // 가정 미리보기
            if showPreview {
                HStack(spacing: 14) {
                    Image(systemName: "house.fill")
                        .font(.title3)
                        .foregroundStyle(AppColors.primary)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(MockData.family.name)
                            .font(.headline)

                        Text("구성원 \(MockData.family.memberCount)명")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                }
                .card()
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            Spacer()
        }
        .alert("유효하지 않은 코드", isPresented: $showInvalidCodeAlert) {
            Button("확인", role: .cancel) {}
        } message: {
            Text("유효하지 않은 코드입니다.\n코드를 다시 확인해주세요.")
        }
    }
}

#Preview("코드 입력 전") {
    JoinFamilyView(onBack: {}, onJoined: { _ in })
}
