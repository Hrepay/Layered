import SwiftUI
import LinkPresentation

// MARK: - 활동 프리셋
struct ActivityPreset: Identifiable, Hashable {
    let id = UUID()
    let icon: String
    let label: String
}

let activityPresets: [ActivityPreset] = [
    ActivityPreset(icon: "fork.knife", label: "외식"),
    ActivityPreset(icon: "cup.and.saucer.fill", label: "카페"),
    ActivityPreset(icon: "film.fill", label: "영화"),
    ActivityPreset(icon: "figure.walk", label: "산책"),
    ActivityPreset(icon: "figure.run", label: "운동"),
    ActivityPreset(icon: "leaf.fill", label: "피크닉"),
    ActivityPreset(icon: "cart.fill", label: "쇼핑"),
    ActivityPreset(icon: "house.fill", label: "집에서"),
    ActivityPreset(icon: "gamecontroller.fill", label: "게임"),
    ActivityPreset(icon: "book.fill", label: "문화생활"),
]

struct CreateMeetingView: View {
    let onBack: () -> Void
    let onCreated: (Meeting, Poll?) -> Void
    @Environment(AppState.self) private var appState: AppState

    @State private var date = Date()
    @State private var place = ""
    @State private var placeURL = ""
    @State private var activity = ""
    @State private var selectedPresets: Set<ActivityPreset> = []
    @State private var showPollCreation = false
    @State private var hasPoll = false
    @State private var createdPoll: Poll?
    @State private var linkMetadata: LPLinkMetadata?
    @State private var isLoadingLink = false

    private var finalActivity: String? {
        let presetLabels = selectedPresets.map(\.label)
        let combined = activity.isEmpty ? presetLabels : presetLabels + [activity]
        return combined.isEmpty ? nil : combined.joined(separator: ", ")
    }

    var body: some View {
        VStack(spacing: 0) {
            NavBar(
                title: "모임 계획하기",
                backAction: onBack,
                trailingText: "등록",
                trailingAction: {
                    Haptic.medium()
                    let meeting = Meeting(
                        id: UUID().uuidString,
                        plannerId: appState.currentUser?.id ?? "",
                        plannerName: appState.currentUser?.name ?? "",
                        meetingDate: date,
                        place: place,
                        placeLatitude: nil,
                        placeLongitude: nil,
                        placeURL: placeURL.isEmpty ? nil : placeURL,
                        activity: finalActivity,
                        status: .planning,
                        hasPoll: hasPoll,
                        createdAt: Date(),
                        updatedAt: Date()
                    )
                    onCreated(meeting, createdPoll)
                },
                trailingDisabled: place.isEmpty
            )

            ScrollView {
                VStack(spacing: 24) {
                    // 날짜 & 시간
                    VStack(alignment: .leading, spacing: 4) {
                        Text("날짜 & 시간")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)

                        DatePicker("", selection: $date, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.graphical)
                            .tint(AppColors.primary)
                            .labelsHidden()
                    }

                    // 장소
                    VStack(alignment: .leading, spacing: 8) {
                        Text("장소")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)

                        AppTextField(placeholder: "장소를 입력해주세요", text: $place)
                    }

                    // 링크 (선택)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("장소 링크 (선택)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)

                        AppTextField(placeholder: "네이버지도, 카카오맵 URL 붙여넣기", text: $placeURL)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.URL)
                            .onChange(of: placeURL) { _, newValue in
                                fetchLinkPreview(newValue)
                            }

                        if isLoadingLink {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("링크 미리보기 로딩 중...")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        } else if let metadata = linkMetadata {
                            LinkPreviewCard(metadata: metadata)
                        }
                    }

                    // 활동 내용
                    VStack(alignment: .leading, spacing: 12) {
                        Text("활동 내용 (선택)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)

                        // 프리셋 그리드 (다중 선택)
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 10),
                            GridItem(.flexible(), spacing: 10),
                        ], spacing: 10) {
                            ForEach(activityPresets) { preset in
                                let isSelected = selectedPresets.contains(preset)
                                Button {
                                    Haptic.light()
                                    if isSelected {
                                        selectedPresets.remove(preset)
                                    } else if selectedPresets.count < 4 {
                                        selectedPresets.insert(preset)
                                    }
                                } label: {
                                    HStack(spacing: 10) {
                                        Image(systemName: preset.icon)
                                            .font(.body)
                                            .frame(width: 24)
                                        Text(preset.label)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                    }
                                    .foregroundStyle(isSelected ? .white : .primary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(isSelected ? AppColors.primary : Color(.secondarySystemBackground))
                                    )
                                }
                            }
                        }

                        // 직접 입력
                        AppTextField(placeholder: "직접 입력", text: $activity)
                    }

                    // 투표 추가
                    if hasPoll {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(AppColors.secondary)
                            Text("투표가 추가되었습니다")
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                            Spacer()
                            Button("삭제") { hasPoll = false }
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                        .card()
                    } else {
                        Button(action: { showPollCreation = true }) {
                            HStack {
                                Image(systemName: "chart.bar.fill")
                                    .foregroundStyle(AppColors.info)
                                Text("투표 추가")
                                    .foregroundStyle(.primary)
                            }
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppColors.infoSubtle)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .fullScreenCover(isPresented: $showPollCreation) {
            CreatePollView(onBack: {
                showPollCreation = false
            }, onCreated: { poll in
                createdPoll = poll
                hasPoll = true
                showPollCreation = false
            })
            .environment(appState)
        }
        .dismissKeyboardOnTap()
    }

    // MARK: - Helpers

    private func fetchLinkPreview(_ urlString: String) {
        linkMetadata = nil
        guard let url = URL(string: urlString), url.scheme != nil else { return }

        isLoadingLink = true
        let provider = LPMetadataProvider()
        provider.startFetchingMetadata(for: url) { metadata, _ in
            DispatchQueue.main.async {
                isLoadingLink = false
                linkMetadata = metadata
            }
        }
    }
}

// MARK: - 링크 미리보기 (LPLinkView 래핑)
struct LinkPreviewCard: UIViewRepresentable {
    let metadata: LPLinkMetadata

    func makeUIView(context: Context) -> LPLinkView {
        let linkView = LPLinkView(metadata: metadata)
        linkView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return linkView
    }

    func updateUIView(_ uiView: LPLinkView, context: Context) {
        uiView.metadata = metadata
    }
}

#Preview {
    CreateMeetingView(onBack: {}, onCreated: { _, _ in })
}
