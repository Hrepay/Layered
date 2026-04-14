import SwiftUI

struct FamilyManagementView: View {
    let onBack: () -> Void
    @Environment(AppState.self) private var appState: AppState?

    @State private var showLeaveAlert = false
    @State private var showDeleteAlert = false
    @State private var showRenameAlert = false
    @State private var newFamilyName = ""

    private var isAdmin: Bool {
        guard let appState else { return false }
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
                Button(action: {
                    newFamilyName = appState?.currentFamily?.name ?? ""
                    showRenameAlert = true
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "pencil.line")
                            .foregroundStyle(AppColors.primary)

                        Text("가정 이름 변경")
                            .foregroundStyle(.primary)

                        Spacer()

                        Text(appState?.currentFamily?.name ?? "")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(16)
                }

                Divider()
                    .padding(.leading, 44)

                // 나가기 버튼
                Button(action: {
                    showLeaveAlert = true
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "rectangle.portrait.and.arrow.right.fill")
                            .foregroundStyle(.red)

                        Text("가정 나가기")
                            .foregroundStyle(.primary)

                        Spacer()
                    }
                    .padding(16)
                }

                Divider()
                    .padding(.leading, 44)

                // 삭제 버튼 (관리자만)
                if isAdmin {
                    Button(action: {
                        showDeleteAlert = true
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "trash.fill")
                                .foregroundStyle(.red)

                            Text("가정 삭제")
                                .foregroundStyle(.primary)

                            Spacer()
                        }
                        .padding(16)
                    }
                }
            }
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 20)
            .padding(.top, 24)

            Spacer()
        }
        .alert("가정 이름 변경", isPresented: $showRenameAlert) {
            TextField("가정 이름", text: $newFamilyName)
            Button("취소", role: .cancel) {}
            Button("변경") {
                guard !newFamilyName.isEmpty else { return }
                Task { try? await appState?.updateFamilyName(newFamilyName) }
            }
        } message: {
            Text("새로운 가정 이름을 입력해주세요.")
        }
        .alert("가정 나가기", isPresented: $showLeaveAlert) {
            Button("취소", role: .cancel) {}
            Button("나가기", role: .destructive) {
                Task { try? await appState?.leaveFamily() }
            }
        } message: {
            Text("정말 나가시겠습니까?\n가정 데이터에서 제외됩니다.")
        }
        .alert("가정 삭제", isPresented: $showDeleteAlert) {
            Button("취소", role: .cancel) {}
            Button("삭제", role: .destructive) {
                Task { try? await appState?.deleteFamily() }
            }
        } message: {
            Text("모든 데이터가 삭제됩니다.\n이 작업은 되돌릴 수 없습니다.")
        }
    }
}

#Preview {
    FamilyManagementView(onBack: {})
}
