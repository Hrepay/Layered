import SwiftUI

struct JoinFamilyView: View {
    let onBack: () -> Void
    let onJoined: (Family) -> Void
    @Environment(AppState.self) private var appState: AppState?

    @State private var code = ""
    @State private var showPreview = false
    @State private var showInvalidCodeAlert = false
    @State private var previewFamily: Family?
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 0) {
            NavBar(
                backAction: onBack,
                trailingText: showPreview ? "참여하기" : "확인",
                trailingAction: {
                    Haptic.light()
                    if showPreview, let family = previewFamily {
                        joinFamily(family)
                    } else {
                        verifyCode()
                    }
                },
                trailingDisabled: code.isEmpty || isLoading
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
            if showPreview, let family = previewFamily {
                HStack(spacing: 14) {
                    Image(systemName: "house.fill")
                        .font(.title3)
                        .foregroundStyle(AppColors.primary)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(family.name)
                            .font(.headline)

                        Text("구성원 \(family.memberCount)명")
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

            if isLoading {
                ProgressView()
                    .padding(.top, 20)
            }

            Spacer()
        }
        .alert("유효하지 않은 코드", isPresented: $showInvalidCodeAlert) {
            Button("확인", role: .cancel) {}
        } message: {
            Text("유효하지 않은 코드입니다.\n코드를 다시 확인해주세요.")
        }
        .swipeBack(onBack: onBack)
        .dismissKeyboardOnTap()
    }

    private func verifyCode() {
        guard let appState else { return }
        isLoading = true
        Task {
            do {
                let family = try await appState.familyRepository.verifyInviteCode(inviteCode: code)
                previewFamily = family
                withAnimation(.easeInOut(duration: 0.25)) {
                    showPreview = true
                }
            } catch {
                showInvalidCodeAlert = true
            }
            isLoading = false
        }
    }

    private func joinFamily(_ family: Family) {
        onJoined(family)
    }
}

#Preview("코드 입력 전") {
    JoinFamilyView(onBack: {}, onJoined: { _ in })
}
