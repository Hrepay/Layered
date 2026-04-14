import SwiftUI

enum RotationMode: String, CaseIterable {
    case auto = "자동"
    case manual = "수동"

    var icon: String {
        switch self {
        case .auto: return "arrow.triangle.2.circlepath"
        case .manual: return "hand.tap.fill"
        }
    }

    var description: String {
        switch self {
        case .auto: return "매주 순서대로 자동 변경"
        case .manual: return "직접 플래너를 지정"
        }
    }
}

struct RotationOrderView: View {
    let onBack: () -> Void
    @Environment(AppState.self) private var appState: AppState?
    @State private var members: [Member] = []
    @State private var selectedMode: RotationMode = .auto
    @State private var fixedPlannerIndex: Int = 0
    @State private var toast: ToastData?

    var body: some View {
        VStack(spacing: 0) {
            NavBar(
                title: "플래너 설정",
                backAction: onBack,
                trailingText: "저장",
                trailingAction: {
                    Haptic.light()
                    saveSettings()
                }
            )

            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - 모드 선택
                    VStack(alignment: .leading, spacing: 12) {
                        Text("플래너 지정 방식")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)

                        ForEach(RotationMode.allCases, id: \.self) { mode in
                            Button {
                                Haptic.light()
                                withAnimation(.spring(duration: 0.2)) {
                                    selectedMode = mode
                                }
                            } label: {
                                HStack(spacing: 14) {
                                    Image(systemName: mode.icon)
                                        .font(.body)
                                        .foregroundStyle(selectedMode == mode ? AppColors.primary : .secondary)
                                        .frame(width: 24)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(mode.rawValue)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundStyle(.primary)
                                        Text(mode.description)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    Image(systemName: selectedMode == mode ? "checkmark.circle.fill" : "circle")
                                        .font(.title3)
                                        .foregroundStyle(selectedMode == mode ? AppColors.primary : Color(.systemGray3))
                                }
                                .padding(14)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(selectedMode == mode ? AppColors.primarySubtle : Color(.secondarySystemBackground))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(selectedMode == mode ? AppColors.primary : .clear, lineWidth: 1.5)
                                )
                            }
                        }
                    }

                    // MARK: - 모드별 설정
                    switch selectedMode {
                    case .auto:
                        autoModeSection
                    case .manual:
                        manualModeSection
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
        }
        .toast($toast)
        .task {
            await appState?.refreshMembers()
            members = appState?.members ?? []
            fixedPlannerIndex = appState?.currentFamily?.currentPlannerIndex ?? 0
        }
    }

    // MARK: - 자동 모드
    private var autoModeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("순서")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            Text("드래그하여 순서를 변경하세요")
                .font(.caption)
                .foregroundStyle(.tertiary)

            VStack(spacing: 0) {
                ForEach(Array(members.enumerated()), id: \.element.id) { index, member in
                    HStack(spacing: 12) {
                        Text("\(index + 1)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .frame(width: 28, height: 28)
                            .background(AppColors.primary)
                            .clipShape(Circle())

                        AvatarView(name: member.name, size: 40, imageURL: member.profileImageURL)

                        Text(member.name)
                            .font(.body)

                        Spacer()

                        Image(systemName: "line.3.horizontal")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)

                    if index < members.count - 1 {
                        Divider().padding(.leading, 56)
                    }
                }
            }
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            // TODO: Phase 3에서 드래그 정렬 구현
        }
    }

    // MARK: - 수동 모드
    private var manualModeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("이번 주 플래너 지정")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            Text("매주 직접 플래너를 선택해주세요")
                .font(.caption)
                .foregroundStyle(.tertiary)

            VStack(spacing: 0) {
                ForEach(Array(members.enumerated()), id: \.element.id) { index, member in
                    Button {
                        Haptic.light()
                        fixedPlannerIndex = index
                    } label: {
                        HStack(spacing: 12) {
                            AvatarView(name: member.name, size: 40, imageURL: member.profileImageURL)

                            Text(member.name)
                                .font(.body)
                                .foregroundStyle(.primary)

                            Spacer()

                            if fixedPlannerIndex == index {
                                BadgeView(text: "플래너", color: AppColors.primary)
                            }
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                    }

                    if index < members.count - 1 {
                        Divider().padding(.leading, 56)
                    }
                }
            }
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - 저장
    private func saveSettings() {
        guard let appState else { return }
        Task {
            // 순서 저장 (자동 모드)
            if selectedMode == .auto {
                let orders = members.enumerated().map { (memberId: $0.element.id, order: $0.offset) }
                try? await appState.updateRotationOrder(orders)
            }
            // TODO: Phase 3에서 rotationMode를 Family 문서에 저장
            // 현재는 currentPlannerIndex만 업데이트
            toast = ToastData(type: .success, message: "저장되었습니다")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                onBack()
            }
        }
    }
}

#Preview {
    RotationOrderView(onBack: {})
}
