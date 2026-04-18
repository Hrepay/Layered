import SwiftUI

struct FamilyManagementView: View {
    let onBack: () -> Void
    @Environment(AppState.self) private var appState: AppState

    @State private var showLeaveAlert = false
    @State private var showDeleteAlert = false
    @State private var showRenameAlert = false
    @State private var newFamilyName = ""

    private var isAdmin: Bool {
        // appState is non-optional
        return appState.currentUser?.id == appState.currentFamily?.adminId
    }

    var body: some View {
        VStack(spacing: 0) {
            NavBar(
                title: "가정 관리",
                backAction: onBack
            )

            VStack(spacing: 0) {
                // 가정 이름 변경
                row(
                    icon: "pencil.line",
                    iconColor: AppColors.primary,
                    title: "가정 이름 변경",
                    trailing: appState.currentFamily?.name
                ) {
                    newFamilyName = appState.currentFamily?.name ?? ""
                    showRenameAlert = true
                }

                Divider().padding(.leading, 66)

                // 나가기 버튼
                row(
                    icon: "rectangle.portrait.and.arrow.right.fill",
                    iconColor: AppColors.primary,
                    title: "가정 나가기"
                ) {
                    showLeaveAlert = true
                }

                if isAdmin {
                    Divider().padding(.leading, 66)

                    // 삭제 버튼 (관리자만)
                    row(
                        icon: "trash.fill",
                        iconColor: AppColors.primary,
                        title: "가정 삭제"
                    ) {
                        showDeleteAlert = true
                    }
                }
            }
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal, 20)
            .padding(.top, 24)

            Spacer()
        }
        .alert("가정 이름 변경", isPresented: $showRenameAlert) {
            TextField("가정 이름", text: $newFamilyName)
            Button("취소", role: .cancel) {}
            Button("변경") {
                guard !newFamilyName.isEmpty else { return }
                Task {
                    do { try await appState.updateFamilyName(newFamilyName) }
                    catch { appState.error = AppError.from(error) }
                }
            }
        } message: {
            Text("새로운 가정 이름을 입력해주세요.")
        }
        .alert("가정 나가기", isPresented: $showLeaveAlert) {
            Button("취소", role: .cancel) {}
            Button("나가기", role: .destructive) {
                Task {
                    do { try await appState.leaveFamily() }
                    catch { appState.error = AppError.from(error) }
                }
            }
        } message: {
            Text("정말 나가시겠습니까?\n가정 데이터에서 제외됩니다.")
        }
        .alert("가정 삭제", isPresented: $showDeleteAlert) {
            Button("취소", role: .cancel) {}
            Button("삭제", role: .destructive) {
                Task {
                    do { try await appState.deleteFamily() }
                    catch { appState.error = AppError.from(error) }
                }
            }
        } message: {
            Text("모든 데이터가 삭제됩니다.\n이 작업은 되돌릴 수 없습니다.")
        }
        .swipeBack(onBack: onBack)
    }

    private func row(icon: String, iconColor: Color, title: String, trailing: String? = nil, action: @escaping () -> Void) -> some View {
        Button {
            Haptic.light()
            action()
        } label: {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundStyle(iconColor)
                    .frame(width: 36, height: 36)
                    .background(Color(.systemBackground))
                    .clipShape(Circle())

                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)

                Spacer()

                if let trailing {
                    Text(trailing)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    FamilyManagementView(onBack: {})
}
