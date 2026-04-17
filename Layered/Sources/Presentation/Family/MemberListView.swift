import SwiftUI

struct MemberListView: View {
    let onBack: () -> Void
    @Environment(AppState.self) private var appState: AppState?

    @State private var showKickAlert = false
    @State private var memberToKick: Member?

    private var members: [Member] { appState?.members ?? [] }
    private var family: Family? { appState?.currentFamily }
    private var currentUserId: String { appState?.currentUser?.id ?? "" }

    var body: some View {
        VStack(spacing: 0) {
            NavBar(
                title: "구성원",
                backAction: onBack
            )

            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(members) { member in
                        memberRow(member)

                        if member.id != members.last?.id {
                            Divider()
                                .padding(.leading, 76)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
        }
        .alert("구성원 강퇴", isPresented: $showKickAlert) {
            Button("취소", role: .cancel) {}
            Button("강퇴", role: .destructive) {
                if let memberId = memberToKick?.id, let appState {
                    Task { try? await appState.removeMember(memberId) }
                }
            }
        } message: {
            Text("\(memberToKick?.name ?? "")님을 정말 강퇴하시겠습니까?")
        }
        .task {
            await appState?.refreshMembers()
        }
        .swipeBack(onBack: onBack)
    }

    private func memberRow(_ member: Member) -> some View {
        HStack(spacing: 12) {
            AvatarView(name: member.name, size: 44, imageURL: member.profileImageURL)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(member.name)
                        .font(.body)

                    if member.role == .admin {
                        BadgeView(text: "관리자", color: AppColors.primary)
                    }
                }

                Text("플래너 순서: \(member.rotationOrder + 1)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if member.role != .admin && family?.adminId == currentUserId {
                Button(action: {
                    memberToKick = member
                    showKickAlert = true
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.body)
                        .foregroundStyle(.red.opacity(0.5))
                }
            }
        }
        .padding(.vertical, 14)
    }
}

#Preview {
    MemberListView(onBack: {})
}
