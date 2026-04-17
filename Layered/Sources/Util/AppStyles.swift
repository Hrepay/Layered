import SwiftUI

// MARK: - 버튼 스타일
struct PrimaryButtonStyle: ButtonStyle {
    var isEnabled: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isEnabled ? AppColors.primary : Color(.systemGray4))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.spring(duration: 0.2), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(AppColors.primarySubtle)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.spring(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - 카드 스타일
struct CardModifier: ViewModifier {
    var highlighted: Bool = false

    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(highlighted ? AppColors.primarySubtle : Color(.secondarySystemBackground))
            )
    }
}

struct TappableCardModifier: ViewModifier {
    @State private var isPressed = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.98 : 1)
            .opacity(isPressed ? 0.9 : 1)
            .animation(.spring(duration: 0.15), value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
    }
}

extension View {
    func card(highlighted: Bool = false) -> some View {
        modifier(CardModifier(highlighted: highlighted))
    }

    func tappableCard() -> some View {
        modifier(TappableCardModifier())
    }
}

// MARK: - 뱃지
struct BadgeView: View {
    let text: String
    var color: Color = AppColors.primary

    var body: some View {
        Text(text)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color)
            .clipShape(Capsule())
    }
}

// MARK: - 아바타
struct AvatarView: View {
    let name: String
    var size: CGFloat = 44
    var imageURL: String? = nil

    private var fontSize: Font {
        if size <= 32 { return .caption }
        if size <= 44 { return .headline }
        return .title
    }

    var body: some View {
        if let imageURL, let url = URL(string: imageURL) {
            CachedAsyncImage(url: url)
                .frame(width: size, height: size)
                .clipShape(Circle())
        } else {
            initialView
        }
    }

    private var initialView: some View {
        Circle()
            .fill(AppColors.primarySubtle)
            .frame(width: size, height: size)
            .overlay {
                Text(String(name.prefix(1)))
                    .font(fontSize)
                    .fontWeight(.medium)
            }
    }
}

// MARK: - 상단 네비게이션 바
struct NavBar: View {
    var title: String = ""
    var backAction: (() -> Void)? = nil
    var trailingText: String? = nil
    var trailingAction: (() -> Void)? = nil
    var trailingDisabled: Bool = false
    var trailingMenu: AnyView? = nil

    var body: some View {
        HStack {
            if let backAction {
                Button(action: backAction) {
                    Image(systemName: "chevron.left")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .frame(width: 44, height: 44)
                }
            }

            Spacer()

            if !title.isEmpty {
                Text(title)
                    .font(.headline)
            }

            Spacer()

            if let trailingMenu {
                trailingMenu
                    .frame(width: 44, height: 44)
            } else if let trailingText, let trailingAction {
                Button(action: trailingAction) {
                    Text(trailingText)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(trailingDisabled ? .secondary : AppColors.primary)
                }
                .disabled(trailingDisabled)
                .frame(minWidth: 44)
                .frame(height: 44)
            } else if backAction != nil {
                Color.clear.frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, 4)
    }
}

// MARK: - 입력 필드
struct AppTextField: View {
    let placeholder: String
    @Binding var text: String
    @FocusState private var isFocused: Bool

    var body: some View {
        TextField(placeholder, text: $text)
            .padding(16)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isFocused ? AppColors.primary : .clear, lineWidth: 1.5)
            )
            .focused($isFocused)
    }
}

// MARK: - 햅틱
enum Haptic {
    static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func medium() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}

// MARK: - 스와이프로 뒤로가기 (fullScreenCover용)
struct SwipeBackModifier: ViewModifier {
    let onBack: () -> Void

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .leading) {
                Color.clear
                    .frame(width: 20)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 10)
                            .onEnded { value in
                                if value.translation.width > 60 {
                                    Haptic.light()
                                    onBack()
                                }
                            }
                    )
                    .ignoresSafeArea()
            }
    }
}

extension View {
    func swipeBack(onBack: @escaping () -> Void) -> some View {
        modifier(SwipeBackModifier(onBack: onBack))
    }

}
