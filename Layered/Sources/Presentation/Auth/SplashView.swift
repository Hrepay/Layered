import SwiftUI

struct SplashView: View {
    @State private var circleScale: CGFloat = 0       // 0 = 숨김, 1 = 정상
    @State private var rotationAngle: Double = 0      // 회전
    @State private var mergeProgress: CGFloat = 1     // 1 = 각자 위치, 0 = 중앙 합체
    @State private var nonPrimaryOpacity: Double = 1  // 1 = 모두 보임, 0 = primary만 남음
    @State private var finalScale: CGFloat = 1
    @State private var textOpacity: Double = 0

    private let circleSize: CGFloat = 90
    private let baseOffset: CGFloat = 32

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // 4개 원 애니메이션
                ZStack {
                    coloredCircle(color: AppColors.info, offset: CGPoint(x: -baseOffset, y: -baseOffset), isPrimary: false)     // 좌상
                    coloredCircle(color: AppColors.warning, offset: CGPoint(x: -baseOffset, y: baseOffset), isPrimary: false)   // 좌하
                    coloredCircle(color: AppColors.secondary, offset: CGPoint(x: baseOffset, y: baseOffset), isPrimary: false)  // 우하
                    coloredCircle(color: AppColors.primary, offset: CGPoint(x: baseOffset, y: -baseOffset), isPrimary: true)    // 우상 (최종 색)
                }
                .frame(width: circleSize * 2.5, height: circleSize * 2.5)
                .rotationEffect(.degrees(rotationAngle))
                .scaleEffect(finalScale)

                Text("겹겹")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(.primary)
                    .opacity(textOpacity)

                Text("가족과 함께하는 따뜻한 시간")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .opacity(textOpacity)

                Spacer().frame(height: 24)

                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(AppColors.primary)
                    .opacity(textOpacity)

                Spacer()
                Spacer()
            }
        }
        .onAppear {
            startAnimation()
        }
    }

    private func coloredCircle(color: Color, offset: CGPoint, isPrimary: Bool) -> some View {
        Circle()
            .fill(color.opacity(0.75))
            .frame(width: circleSize, height: circleSize)
            .scaleEffect(circleScale)
            .offset(x: offset.x * mergeProgress, y: offset.y * mergeProgress)
            .opacity(isPrimary ? 1 : nonPrimaryOpacity)
            .blendMode(.multiply)
    }

    private func startAnimation() {
        // Phase 1: 원 4개 나타나기 (0~0.6초)
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            circleScale = 1
        }

        // Phase 2: 뱅글뱅글 천천히 회전 (0.4~2.4초) — 2바퀴
        withAnimation(.easeInOut(duration: 2.0).delay(0.4)) {
            rotationAngle = 720
        }

        // Phase 3: 중앙으로 합체 + 비-primary 페이드아웃 (2.4~3.0초)
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(2.4)) {
            mergeProgress = 0
        }
        withAnimation(.easeOut(duration: 0.5).delay(2.5)) {
            nonPrimaryOpacity = 0
        }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.65).delay(2.8)) {
            finalScale = 1.15
        }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7).delay(3.1)) {
            finalScale = 1.0
        }

        // Phase 4: 텍스트 등장 (3.0초 이후)
        withAnimation(.easeOut(duration: 0.5).delay(3.0)) {
            textOpacity = 1
        }
    }
}

#Preview {
    SplashView()
}
