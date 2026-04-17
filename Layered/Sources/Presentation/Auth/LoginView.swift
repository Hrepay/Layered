import SwiftUI

struct LoginView: View {
    let onSignIn: () -> Void
    var onDebugSignIn: ((String, String) -> Void)?

    @State private var appeared = false

    #if DEBUG
    // Xcode Scheme → Run → Arguments → Environment Variables 에서 DEBUG_EMAIL, DEBUG_PASSWORD 설정 시에만 노출
    private var debugCredentials: (String, String)? {
        let env = ProcessInfo.processInfo.environment
        guard let email = env["DEBUG_EMAIL"], !email.isEmpty,
              let password = env["DEBUG_PASSWORD"], !password.isEmpty else { return nil }
        return (email, password)
    }
    #endif

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // 로고 섹션
            VStack(spacing: 16) {
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)

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

                #if DEBUG
                if let (debugEmail, debugPassword) = debugCredentials {
                    Button(action: {
                        Haptic.light()
                        onDebugSignIn?(debugEmail, debugPassword)
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "envelope.fill")
                                .font(.title3)
                            Text("테스트 계정 로그인")
                                .font(.headline)
                        }
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
                #endif

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
