import SwiftUI

struct InviteMemberView: View {
    let onBack: () -> Void
    @State private var inviteCode = "ABC123"
    @State private var copied = false

    var body: some View {
        VStack(spacing: 0) {
            NavBar(
                title: "초대하기",
                backAction: onBack
            )

            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 48))
                    .foregroundStyle(AppColors.primary)

                Text("초대 코드를 공유해주세요")
                    .font(.title3)
                    .fontWeight(.bold)
            }

            Spacer()
                .frame(height: 32)

            // 코드 카드
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
                .frame(height: 16)

            // 코드 재발급
            Button(action: {
                Haptic.light()
                inviteCode = String((0..<6).map { _ in "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".randomElement()! })
                copied = false
            }) {
                Text("코드 재발급")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }
}

#Preview {
    InviteMemberView(onBack: {})
}
