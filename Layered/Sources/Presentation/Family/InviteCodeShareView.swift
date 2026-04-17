import SwiftUI

struct InviteCodeShareView: View {
    let inviteCode: String
    let onDone: () -> Void

    @State private var copied = false

    var body: some View {
        VStack(spacing: 0) {
            NavBar(
                trailingText: "완료",
                trailingAction: {
                    Haptic.light()
                    onDone()
                }
            )

            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(AppColors.secondary)

                Text("가정이 만들어졌어요!")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("아래 코드를 가족에게 공유해주세요")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
                .frame(height: 32)

            // 초대 코드 카드
            VStack(spacing: 8) {
                Text(inviteCode)
                    .font(.system(size: 36, weight: .bold, design: .monospaced))
                    .kerning(6)

                Text("30분 후 만료됩니다")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .card()
            .padding(.horizontal, 24)

            Spacer()
                .frame(height: 24)

            // 복사 + 공유 버튼
            HStack(spacing: 12) {
                Button(action: {
                    UIPasteboard.general.string = inviteCode
                    Haptic.light()
                    copied = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        copied = false
                    }
                }) {
                    Label(copied ? "복사됨" : "복사", systemImage: copied ? "checkmark" : "doc.on.doc.fill")
                }
                .buttonStyle(SecondaryButtonStyle())

                ShareLink(item: "겹겹 가정 초대 코드: \(inviteCode)") {
                    Label("공유", systemImage: "square.and.arrow.up.fill")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppColors.primarySubtle)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .swipeBack(onBack: onDone)
    }
}

#Preview {
    InviteCodeShareView(inviteCode: "ABC123", onDone: {})
}
