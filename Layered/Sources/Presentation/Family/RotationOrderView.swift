import SwiftUI

struct RotationOrderView: View {
    let onBack: () -> Void
    @State private var members = MockData.members

    var body: some View {
        VStack(spacing: 0) {
            NavBar(
                backAction: onBack,
                trailingText: "저장",
                trailingAction: {
                    Haptic.light()
                }
            )

            Text("드래그하여 순서를 변경하세요")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 12)
                .padding(.bottom, 8)

            List {
                ForEach(Array(members.enumerated()), id: \.element.id) { index, member in
                    HStack(spacing: 12) {
                        Text("\(index + 1)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .frame(width: 28, height: 28)
                            .background(AppColors.primary)
                            .clipShape(Circle())

                        AvatarView(name: member.name, size: 40)

                        Text(member.name)
                            .font(.body)

                        Spacer()

                        Image(systemName: "line.3.horizontal")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 6)
                    .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                    .listRowSeparator(.hidden)
                }
                .onMove { from, to in
                    members.move(fromOffsets: from, toOffset: to)
                    for i in members.indices {
                        members[i].rotationOrder = i
                    }
                }
            }
            .listStyle(.plain)
            .environment(\.editMode, .constant(.active))
        }
    }
}

#Preview {
    RotationOrderView(onBack: {})
}
