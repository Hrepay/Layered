import SwiftUI
import LinkPresentation

struct EditMeetingView: View {
    let meeting: Meeting
    let onBack: () -> Void
    let onSaved: (Meeting) -> Void

    @State private var date: Date
    @State private var place: String
    @State private var placeURL: String
    @State private var activity: String
    @State private var selectedPresets: Set<ActivityPreset> = []
    @State private var linkMetadata: LPLinkMetadata?
    @State private var isLoadingLink = false
    @State private var showPastDateAlert = false

    private var finalActivity: String? {
        let presetLabels = selectedPresets.map(\.label)
        let combined = activity.isEmpty ? presetLabels : presetLabels + [activity]
        return combined.isEmpty ? nil : combined.joined(separator: ", ")
    }

    init(meeting: Meeting, onBack: @escaping () -> Void, onSaved: @escaping (Meeting) -> Void) {
        self.meeting = meeting
        self.onBack = onBack
        self.onSaved = onSaved
        _date = State(initialValue: meeting.meetingDate)
        _place = State(initialValue: meeting.place)
        _placeURL = State(initialValue: meeting.placeURL ?? "")
        // 기존 활동에서 프리셋 매칭
        var matchedPresets: Set<ActivityPreset> = []
        var remainingActivity = ""
        if let existingActivity = meeting.activity {
            let parts = existingActivity.components(separatedBy: ", ")
            for part in parts {
                if let matched = activityPresets.first(where: { $0.label == part }) {
                    matchedPresets.insert(matched)
                } else {
                    remainingActivity = part
                }
            }
        }
        _selectedPresets = State(initialValue: matchedPresets)
        _activity = State(initialValue: remainingActivity)
    }

    var body: some View {
        VStack(spacing: 0) {
            NavBar(
                title: "모임 수정",
                backAction: onBack,
                trailingText: "저장",
                trailingAction: {
                    Haptic.medium()
                    if date < Date() {
                        showPastDateAlert = true
                    } else {
                        performSave()
                    }
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

                        DatePicker("", selection: $date, displayedComponents: [.date, .hourAndMinute])
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
                                handlePlaceURLChange(newValue)
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

                        AppTextField(placeholder: "직접 입력", text: $activity)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .onAppear {
            if !placeURL.isEmpty {
                fetchLinkPreview(placeURL)
            }
        }
        .swipeBack(onBack: onBack)
        .alert("이미 지난 시점이에요", isPresented: $showPastDateAlert) {
            Button("취소", role: .cancel) {}
            Button("저장") { performSave() }
        } message: {
            Text("선택한 일시가 현재 시점보다 과거입니다.\n저장하면 이 모임은 바로 완료된 모임으로 표시됩니다.")
        }
    }

    private func performSave() {
        var updated = meeting
        updated.meetingDate = date
        updated.place = place
        updated.placeURL = placeURL.isEmpty ? nil : placeURL
        updated.activity = finalActivity
        updated.updatedAt = Date()
        onSaved(updated)
    }

    private func handlePlaceURLChange(_ newValue: String) {
        if let extracted = URLExtractor.firstURL(in: newValue),
           extracted.absoluteString != newValue {
            placeURL = extracted.absoluteString
            return
        }
        fetchLinkPreview(newValue)
    }

    private func fetchLinkPreview(_ urlString: String) {
        linkMetadata = nil
        guard let url = URLExtractor.firstURL(in: urlString) else { return }

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

#Preview {
    EditMeetingView(meeting: MockData.meetings[0], onBack: {}, onSaved: { _ in })
}
