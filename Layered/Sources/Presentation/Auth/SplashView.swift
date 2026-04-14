import SwiftUI

struct SplashView: View {
    @State private var logoOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var logoScale: CGFloat = 0.8

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()

                // 로고 아이콘
                Image(systemName: "person.3.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(AppColors.primary)
                    .opacity(logoOpacity)
                    .scaleEffect(logoScale)

                // 앱 이름
                Text("겹겹")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(.primary)
                    .opacity(textOpacity)

                // 서브타이틀
                Text("가족과 함께하는 따뜻한 시간")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .opacity(textOpacity)

                Spacer()
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                logoOpacity = 1
                logoScale = 1
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
                textOpacity = 1
            }
        }
    }
}

#Preview {
    SplashView()
}
