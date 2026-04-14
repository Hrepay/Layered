import SwiftUI

struct FamilyManagementView: View {
    let onBack: () -> Void
    @State private var showLeaveAlert = false
    @State private var showDeleteAlert = false

    private let isAdmin = MockData.currentUser.id == MockData.family.adminId

    var body: some View {
        VStack(spacing: 0) {
            NavBar(
                title: "가정 관리",
                backAction: onBack
            )

            VStack(spacing: 0) {
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
        .alert("가정 나가기", isPresented: $showLeaveAlert) {
            Button("취소", role: .cancel) {}
            Button("나가기", role: .destructive) {}
        } message: {
            Text("정말 나가시겠습니까?\n가정 데이터에서 제외됩니다.")
        }
        .alert("가정 삭제", isPresented: $showDeleteAlert) {
            Button("취소", role: .cancel) {}
            Button("삭제", role: .destructive) {}
        } message: {
            Text("모든 데이터가 삭제됩니다.\n이 작업은 되돌릴 수 없습니다.")
        }
    }
}

#Preview {
    FamilyManagementView(onBack: {})
}
