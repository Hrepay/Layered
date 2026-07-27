import SwiftUI
import MapKit

// MARK: - 일차 그룹

/// 지도 표시용 일차 묶음 — 좌표 있는 항목만, 방문 순서 정렬.
struct TripDayGroup: Identifiable {
    let day: Int
    let items: [ItineraryItem]
    var id: Int { day }

    static func groups(from items: [ItineraryItem]) -> [TripDayGroup] {
        Dictionary(grouping: items.filter { $0.coordinate != nil }, by: \.day)
            .sorted { $0.key < $1.key }
            .map { TripDayGroup(day: $0.key, items: $0.value.sorted { $0.order < $1.order }) }
    }
}

// MARK: - 지도 레이어 (미리보기·전체 화면 공용)

/// 일차별 색 핀(방문 순서 번호) + 같은 날 동선 연결선.
struct TripMapLayers: MapContent {
    let groups: [TripDayGroup]
    var selectionId: String? = nil
    var onSelect: ((ItineraryItem) -> Void)? = nil

    var body: some MapContent {
        ForEach(groups) { group in
            if group.items.count > 1 {
                MapPolyline(coordinates: group.items.compactMap(\.coordinate))
                    .stroke(
                        TripDayPalette.color(for: group.day).opacity(0.65),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [6, 6])
                    )
            }
            ForEach(Array(group.items.enumerated()), id: \.element.id) { index, item in
                if let coordinate = item.coordinate {
                    Annotation(item.name, coordinate: coordinate) {
                        pin(item: item, number: index + 1)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func pin(item: ItineraryItem, number: Int) -> some View {
        let isSelected = selectionId == item.id
        Text("\(number)")
            .font(.caption)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .frame(width: isSelected ? 34 : 27, height: isSelected ? 34 : 27)
            .background(Circle().fill(TripDayPalette.color(for: item.day)))
            .overlay(Circle().stroke(.white, lineWidth: 2))
            .shadow(color: .black.opacity(0.25), radius: 3, y: 1)
            .animation(.spring(duration: 0.2), value: isSelected)
            .onTapGesture {
                guard let onSelect else { return }
                Haptic.light()
                onSelect(item)
            }
    }
}

// MARK: - 여행 전체 지도

/// 여행 일정 전체를 한눈에 — Day 필터 칩 + 핀 탭 시 하단 요약 카드.
struct TripMapView: View {
    let meeting: Meeting
    let items: [ItineraryItem]
    let onBack: () -> Void

    /// nil이면 전체 일차 표시.
    @State private var selectedDay: Int?
    @State private var selection: ItineraryItem?
    @State private var cameraPosition: MapCameraPosition = .automatic

    private var days: [Int] { Array(1...max(1, meeting.durationDays)) }

    private var allGroups: [TripDayGroup] { TripDayGroup.groups(from: items) }

    private var visibleGroups: [TripDayGroup] {
        guard let selectedDay else { return allGroups }
        return allGroups.filter { $0.day == selectedDay }
    }

    var body: some View {
        VStack(spacing: 0) {
            NavBar(title: "여행 지도", backAction: onBack)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    filterChip(title: "전체", color: AppColors.primary, isOn: selectedDay == nil) {
                        selectedDay = nil
                    }
                    ForEach(days, id: \.self) { day in
                        filterChip(
                            title: "\(day)일차",
                            color: TripDayPalette.color(for: day),
                            isOn: selectedDay == day
                        ) {
                            selectedDay = day
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 10)

            if allGroups.isEmpty {
                Spacer()
                EmptyStateView(
                    icon: "map.fill",
                    title: "지도에 표시할 곳이 없어요",
                    description: "장소 검색으로 일정을 추가하면\n지도에서 한눈에 볼 수 있어요"
                )
                Spacer()
            } else {
                ZStack(alignment: .bottom) {
                    Map(position: $cameraPosition) {
                        TripMapLayers(
                            groups: visibleGroups,
                            selectionId: selection?.id,
                            onSelect: { selection = $0 }
                        )
                        UserAnnotation()
                    }
                    .mapStyle(.standard(pointsOfInterest: .excludingAll))

                    if let selection {
                        summaryCard(selection)
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onChange(of: selectedDay) { _, _ in
            // 필터가 바뀌면 시야를 새 핀 범위로 리셋, 이전 선택 해제
            selection = nil
            cameraPosition = .automatic
        }
        .swipeBack(onBack: onBack)
    }

    // MARK: - 칩

    private func filterChip(title: String, color: Color, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button {
            Haptic.light()
            action()
        } label: {
            HStack(spacing: 5) {
                Circle()
                    .fill(isOn ? .white : color)
                    .frame(width: 8, height: 8)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundStyle(isOn ? .white : .primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Capsule().fill(isOn ? color : Color(.secondarySystemBackground)))
        }
    }

    // MARK: - 하단 요약 카드

    @ViewBuilder
    private func summaryCard(_ item: ItineraryItem) -> some View {
        let dayItems = allGroups.first { $0.day == item.day }?.items ?? []
        let number = (dayItems.firstIndex { $0.id == item.id } ?? 0) + 1

        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text("\(item.day)일차 · \(number)번째")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(TripDayPalette.color(for: item.day)))
                Spacer()
                Button {
                    Haptic.light()
                    selection = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }

            HStack(spacing: 6) {
                Text(item.name)
                    .font(.headline)
                    .fontWeight(.bold)
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

            if let urlString = item.detailURL, let url = URL(string: urlString) {
                Link(destination: url) {
                    HStack(spacing: 4) {
                        Image(systemName: "link")
                            .font(.caption2)
                        Text("카카오맵에서 보기")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Capsule().fill(AppColors.primary))
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.15), radius: 12, y: 4)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

#Preview {
    TripMapView(
        meeting: MockData.meetings.first { $0.id == "meeting-trip" }!,
        items: MockData.itineraryItems,
        onBack: {}
    )
}
