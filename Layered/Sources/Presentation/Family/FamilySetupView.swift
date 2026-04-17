import SwiftUI

enum FamilySetupStep {
    case select
    case create
    case profile(familyName: String)
    case joinProfile(Family)
    case inviteShare(String)
    case join
}

struct FamilySetupView: View {
    let onJoined: (Family) -> Void
    @Environment(AppState.self) private var appState: AppState
    @State private var step: FamilySetupStep = .select

    var body: some View {
        Group {
            switch step {
            case .select:
                familySelectView
            case .create:
                CreateFamilyView(onBack: {
                    step = .select
                }, onCreated: { familyName in
                    step = .profile(familyName: familyName)
                })
            case .profile(let familyName):
                ProfileSetupView(onBack: {
                    step = .create
                }, onComplete: { profileName, image in
                    createFamily(familyName: familyName, profileName: profileName, image: image)
                })
            case .inviteShare(let code):
                InviteCodeShareView(inviteCode: code, onDone: {
                    if let family = appState.currentFamily {
                        onJoined(family)
                    }
                })
            case .join:
                JoinFamilyView(onBack: {
                    step = .select
                }, onJoined: { family in
                    step = .joinProfile(family)
                })
                .environment(appState)
            case .joinProfile(let family):
                ProfileSetupView(onBack: {
                    step = .join
                }, onComplete: { profileName, image in
                    guard let userId = appState.currentUser?.id else { return }
                    appState.isLoading = true
                    Task {
                        do {
                            if let image {
                                try await appState.uploadProfileImage(image)
                            }
                            try await appState.updateProfile(name: profileName, profileImageURL: appState.currentUser?.profileImageURL)
                            // 프로필 완료 후 실제 가정 참여
                            try await appState.familyRepository.joinFamily(familyId: family.id, userId: userId, userName: profileName)
                            appState.isLoading = false
                            onJoined(family)
                        } catch {
                            appState.error = AppError.from(error)
                            appState.isLoading = false
                        }
                    }
                })
            }
        }
        .animation(.easeInOut(duration: 0.25), value: String(describing: step))
    }

    private func createFamily(familyName: String, profileName: String, image: UIImage? = nil) {
        guard let userId = appState.currentUser?.id else { return }
        appState.isLoading = true
        Task {
            do {
                // 프로필 사진 업로드
                if let image {
                    try await appState.uploadProfileImage(image)
                }
                // 프로필 이름 업데이트
                try await appState.updateProfile(name: profileName, profileImageURL: appState.currentUser?.profileImageURL)
                // 가정 생성
                let family = try await appState.familyRepository.createFamily(
                    name: familyName,
                    adminId: userId
                )
                appState.currentFamily = family
                // user.familyId 업데이트
                if var updatedUser = appState.currentUser {
                    updatedUser.familyId = family.id
                    try await appState.userRepository.updateUser(updatedUser)
                    appState.currentUser = updatedUser
                }
                await appState.loadHomeData()
                step = .inviteShare(family.inviteCode)
            } catch {
                appState.error = AppError.from(error)
            }
            appState.isLoading = false
        }
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
