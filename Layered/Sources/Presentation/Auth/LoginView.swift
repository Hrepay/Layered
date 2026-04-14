import SwiftUI

struct LoginView: View {
    let onSignIn: () -> Void

    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // 로고 섹션
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(AppColors.primarySubtle)
                        .frame(width: 100, height: 100)

                    Image(systemName: "person.3.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(AppColors.primary)
                }

                Text("겹겹")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.primary)

                Text("가족과 함께하는 따뜻한 시간을 만들어요")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)

            Spacer()

            // 하단 로그인 영역
            VStack(spacing: 16) {
                // Apple 로그인 버튼
                Button(action: {
                    Haptic.medium()
                    onSignIn()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "apple.logo")
                            .font(.title3)
                        Text("Apple로 로그인")
                            .font(.headline)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                // 약관 안내
                Text("로그인 시 이용약관 및 개인정보 처리방침에 동의합니다")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                appeared = true
            }
        }
    }
}

#Preview {
    LoginView(onSignIn: {})
}
