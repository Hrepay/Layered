import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    var description: String? = nil
    var buttonTitle: String? = nil
    var buttonAction: (() -> Void)? = nil
    var secondaryButtonTitle: String? = nil
    var secondaryButtonAction: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(AppColors.primary)

            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)

            if let description {
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            if let buttonTitle, let buttonAction {
                Button(action: {
                    Haptic.light()
                    buttonAction()
                }) {
                    Text(buttonTitle)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(AppColors.primary)
                        .clipShape(Capsule())
                }
            }

            if let secondaryButtonTitle, let secondaryButtonAction {
                Button(action: {
                    Haptic.light()
                    secondaryButtonAction()
                }) {
                    Text(secondaryButtonTitle)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(AppColors.warningSubtle)
                        .clipShape(Capsule())
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    EmptyStateView(
        icon: "calendar.badge.plus",
        title: "아직 모임이 없어요",
        description: "첫 번째 가족 모임을 계획해보세요",
        buttonTitle: "모임 계획하기",
        buttonAction: {}
    )
}
