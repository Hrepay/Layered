import SwiftUI

/// 일차별 구분 색 — 일정표 순서 뱃지·지도 핀·경로선이 공유.
enum TripDayPalette {
    private static let colors: [Color] = [
        AppColors.primary,
        AppColors.info,
        AppColors.secondary,
        AppColors.warning,
        AppColors.danger,
    ]

    static func color(for day: Int) -> Color {
        colors[(day - 1) % colors.count]
    }
}

/// 여행 상세의 일정표 섹션 — Day 칩 + 일자별 방문 순서 리스트.
/// 항목 로드·추가·수정·삭제를 자체 처리하고, 결과 배열은 부모 바인딩으로 공유(지도에서 재사용).
struct TripItinerarySection: View {
    let meeting: Meeting
    @Binding var items: [ItineraryItem]

    @Environment(AppState.self) private var appState: AppState

    @State private var selectedDay = 1
    @State private var isLoading = true
    @State private var isMutating = false
    @State private var showPlaceSearch = false
    @State private var showManualAdd = false
    @State private var manualName = ""
    @State private var manualMemo = ""
    @State private var memoEditingItem: ItineraryItem?
    @State private var memoText = ""

    /// 여행 일수만큼의 일차 + 기간 축소로 범위를 벗어난 일정이 남은 일차.
    /// (3일 여행 → 2일로 줄여도 3일차에 넣어둔 일정을 보고 정리할 수 있게)
    private var days: [Int] {
        let maxDay = max(meeting.durationDays, items.map(\.day).max() ?? 1)
        return Array(1...max(1, maxDay))
    }

    private var selectedDayItems: [ItineraryItem] {
        items.filter { $0.day == selectedDay }.sorted { $0.order < $1.order }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Text("여행 일정")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                Spacer()
                if !items.isEmpty {
                    Text("\(items.count)곳")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Day 칩
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(days, id: \.self) { day in
                        dayChip(day)
                    }
                }
            }

            if isLoading {
                HStack(spacing: 8) {
                    ProgressView().scaleEffect(0.8)
                    Text("일정 불러오는 중...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
            } else if selectedDayItems.isEmpty {
                Text("아직 계획된 곳이 없어요.\n가고 싶은 곳을 추가해보세요.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 12)
            } else {
                VStack(spacing: 8) {
                    ForEach(Array(selectedDayItems.enumerated()), id: \.element.id) { index, item in
                        itemRow(item, index: index)
                    }
                }
            }

            // 추가 버튼 — 검색 / 직접 입력
            Menu {
                Button("장소 검색", systemImage: "magnifyingglass") {
                    showPlaceSearch = true
                }
                Button("직접 입력", systemImage: "pencil") {
                    manualName = ""
                    manualMemo = ""
                    showManualAdd = true
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(AppColors.primary)
                    Text("\(selectedDay)일차에 장소 추가")
                        .foregroundStyle(.primary)
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(AppColors.primarySubtle)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(isMutating)
        }
        .card()
        .task(id: meeting.id) {
            await reload()
        }
        .sheet(isPresented: $showPlaceSearch) {
            // 여행 일정 검색: '전체'가 관광지·숙소·문화시설까지 포함
            PlaceSearchSheet(onSelect: { selected in
                Task { await addItem(from: selected) }
            }, travelSearch: true)
            .environment(appState)
        }
        .sheet(isPresented: $showManualAdd) {
            manualAddSheet
        }
        .sheet(isPresented: Binding(
            get: { memoEditingItem != nil },
            set: { if !$0 { memoEditingItem = nil } }
        )) {
            memoEditSheet
        }
    }

    // MARK: - Day 칩

    @ViewBuilder
    private func dayChip(_ day: Int) -> some View {
        let isOn = selectedDay == day
        Button {
            Haptic.light()
            selectedDay = day
        } label: {
            HStack(spacing: 5) {
                Circle()
                    .fill(TripDayPalette.color(for: day))
                    .frame(width: 8, height: 8)
                Text("\(day)일차")
                    .font(.subheadline)
                    .fontWeight(.medium)
                if let label = dayDateLabel(day) {
                    Text(label)
                        .font(.caption2)
                        .foregroundStyle(isOn ? .white.opacity(0.85) : .secondary)
                }
            }
            .foregroundStyle(isOn ? .white : .primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Capsule().fill(isOn ? TripDayPalette.color(for: day) : Color(.secondarySystemBackground)))
        }
    }

    /// "7/30 (수)" 형태의 일차 날짜 라벨.
    private func dayDateLabel(_ day: Int) -> String? {
        guard let date = Calendar.current.date(byAdding: .day, value: day - 1, to: meeting.meetingDate) else {
            return nil
        }
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "M/d (E)"
        return f.string(from: date)
    }

    // MARK: - 항목 행

    @ViewBuilder
    private func itemRow(_ item: ItineraryItem, index: Int) -> some View {
        HStack(alignment: .top, spacing: 12) {
            // 방문 순서 뱃지
            Text("\(index + 1)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(width: 24, height: 24)
                .background(Circle().fill(TripDayPalette.color(for: item.day)))
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(item.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    if let category = item.category, !category.isEmpty {
                        Text(category)
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color(.secondarySystemBackground)))
                    }
                }
                if let memo = item.memo, !memo.isEmpty {
                    Text(memo)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }

            Spacer(minLength: 0)

            if let urlString = item.detailURL, let url = URL(string: urlString) {
                Link(destination: url) {
                    Image(systemName: "link")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppColors.primary)
                        .frame(width: 26, height: 26)
                        .background(Circle().fill(AppColors.primarySubtle))
                }
            }

            Menu {
                if index > 0 {
                    Button("위로 이동", systemImage: "arrow.up") {
                        Task { await move(item, offset: -1) }
                    }
                }
                if index < selectedDayItems.count - 1 {
                    Button("아래로 이동", systemImage: "arrow.down") {
                        Task { await move(item, offset: 1) }
                    }
                }
                Button("메모 수정", systemImage: "pencil") {
                    memoText = item.memo ?? ""
                    memoEditingItem = item
                }
                Button("삭제", systemImage: "trash", role: .destructive) {
                    Task { await delete(item) }
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(width: 26, height: 26)
                    .background(Circle().fill(Color(.secondarySystemBackground)))
            }
            .disabled(isMutating)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }

    // MARK: - 직접 입력 시트

    @ViewBuilder
    private var manualAddSheet: some View {
        NavigationStack {
            VStack(spacing: 16) {
                AppTextField(placeholder: "장소명", text: $manualName)
                AppTextField(placeholder: "메모 (선택)", text: $manualMemo)
                Spacer()
            }
            .padding(20)
            .navigationTitle("\(selectedDay)일차 장소 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { showManualAdd = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("추가") {
                        Task { await addManualItem() }
                    }
                    .disabled(manualName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isMutating)
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - 메모 수정 시트

    @ViewBuilder
    private var memoEditSheet: some View {
        NavigationStack {
            VStack(spacing: 16) {
                AppTextField(placeholder: "메모", text: $memoText)
                Spacer()
            }
            .padding(20)
            .navigationTitle(memoEditingItem?.name ?? "메모 수정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { memoEditingItem = nil }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        Task { await saveMemo() }
                    }
                    .disabled(isMutating)
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - 데이터 동작

    @MainActor
    private func reload() async {
        isLoading = true
        defer { isLoading = false }
        items = (try? await appState.getItineraryItems(meetingId: meeting.id)) ?? []
    }

    @MainActor
    private func addItem(from place: PlaceResult) async {
        let item = ItineraryItem.from(place: place, day: selectedDay, order: selectedDayItems.count)
        await add(item)
    }

    @MainActor
    private func addManualItem() async {
        let name = manualName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        let memo = manualMemo.trimmingCharacters(in: .whitespacesAndNewlines)
        let item = ItineraryItem(
            id: UUID().uuidString,
            day: selectedDay,
            order: selectedDayItems.count,
            name: name,
            placeId: nil,
            latitude: nil,
            longitude: nil,
            category: nil,
            detailURL: nil,
            memo: memo.isEmpty ? nil : memo,
            createdAt: Date(),
            updatedAt: Date()
        )
        await add(item)
        showManualAdd = false
    }

    @MainActor
    private func add(_ item: ItineraryItem) async {
        isMutating = true
        defer { isMutating = false }
        do {
            let created = try await appState.addItineraryItem(meetingId: meeting.id, item: item)
            items.append(created)
            Haptic.success()
        } catch {
            appState.error = AppError.from(error)
        }
    }

    @MainActor
    private func delete(_ item: ItineraryItem) async {
        isMutating = true
        defer { isMutating = false }
        do {
            try await appState.deleteItineraryItem(meetingId: meeting.id, itemId: item.id)
            items.removeAll { $0.id == item.id }
            // 같은 일차의 뒤 항목들 순서 당김
            var reindexed: [ItineraryItem] = []
            for (index, var dayItem) in selectedDayItems.enumerated() where dayItem.order != index {
                dayItem.order = index
                reindexed.append(dayItem)
            }
            if !reindexed.isEmpty {
                try await appState.reorderItineraryItems(meetingId: meeting.id, items: reindexed)
                applyLocal(reindexed)
            }
        } catch {
            appState.error = AppError.from(error)
        }
    }

    @MainActor
    private func move(_ item: ItineraryItem, offset: Int) async {
        let dayItems = selectedDayItems
        guard let index = dayItems.firstIndex(where: { $0.id == item.id }),
              dayItems.indices.contains(index + offset) else { return }
        var a = dayItems[index]
        var b = dayItems[index + offset]
        swap(&a.order, &b.order)

        isMutating = true
        defer { isMutating = false }
        do {
            try await appState.reorderItineraryItems(meetingId: meeting.id, items: [a, b])
            applyLocal([a, b])
            Haptic.light()
        } catch {
            appState.error = AppError.from(error)
        }
    }

    @MainActor
    private func saveMemo() async {
        guard var item = memoEditingItem else { return }
        let memo = memoText.trimmingCharacters(in: .whitespacesAndNewlines)
        item.memo = memo.isEmpty ? nil : memo
        item.updatedAt = Date()

        isMutating = true
        defer { isMutating = false }
        do {
            try await appState.updateItineraryItem(meetingId: meeting.id, item: item)
            applyLocal([item])
            memoEditingItem = nil
        } catch {
            appState.error = AppError.from(error)
        }
    }

    /// 변경된 항목들을 로컬 배열에 반영.
    private func applyLocal(_ changed: [ItineraryItem]) {
        for item in changed {
            if let index = items.firstIndex(where: { $0.id == item.id }) {
                items[index] = item
            }
        }
    }
}

#Preview {
    ScrollView {
        TripItinerarySection(
            meeting: MockData.meetings.first { $0.id == "meeting-trip" }!,
            items: .constant(MockData.itineraryItems)
        )
        .padding(20)
    }
    .environment(AppState())
}
