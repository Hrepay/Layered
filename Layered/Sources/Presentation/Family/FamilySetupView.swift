import SwiftUI

enum FamilySetupStep {
    case select
    case create
    case inviteShare(String) // 초대 코드
    case join
    case profile
}

struct FamilySetupView: View {
    let onJoined: (Family) -> Void
    @State private var step: FamilySetupStep = .select

    var body: some View {
        Group {
            switch step {
            case .select:
                familySelectView
            case .create:
                CreateFamilyView(onBack: {
                    step = .select
                }, onCreated: { family in
                    step = .inviteShare(family.inviteCode)
                })
            case .inviteShare(let code):
                InviteCodeShareView(inviteCode: code, onDone: {
                    step = .profile
                })
            case .join:
                JoinFamilyView(onBack: {
                    step = .select
                }, onJoined: { _ in
                    step = .profile
                })
            case .profile:
                ProfileSetupView(onBack: {
                    step = .select
                }, onComplete: {
                    onJoined(MockData.family)
                })
            }
        }
        .animation(.easeInOut(duration: 0.25), value: String(describing: step))
    }

    private var familySelectView: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "house.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(AppColors.primary)

                Text("가정을 설정해주세요")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("가정을 새로 만들거나\n초대 코드로 기존 가정에 참여하세요")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
                .frame(height: 48)

            VStack(spacing: 12) {
                Button(action: {
                    Haptic.light()
                    step = .create
                }) {
                    Text("새 가정 만들기")
                }
                .buttonStyle(PrimaryButtonStyle())

                Button(action: {
                    Haptic.light()
                    step = .join
                }) {
                    Text("초대 코드로 참여")
                }
                .buttonStyle(SecondaryButtonStyle())
            }
            .padding(.horizontal, 24)

            Spacer()
        }
    }
}

#Preview {
    FamilySetupView(onJoined: { _ in })
}
