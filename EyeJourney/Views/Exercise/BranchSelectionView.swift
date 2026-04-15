import SwiftUI

/// 갈림길에서 시선으로 방향을 선택하는 뷰
struct BranchSelectionView: View {
    let branch: BranchChoice
    let onSelect: (BranchOption) -> Void

    @State private var dwellProgress: [Float]
    @State private var selectedIndex: Int?

    init(branch: BranchChoice, onSelect: @escaping (BranchOption) -> Void) {
        self.branch = branch
        self.onSelect = onSelect
        _dwellProgress = State(initialValue: Array(repeating: 0, count: branch.options.count))
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("갈림길")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("가고 싶은 방향을 3초간 바라보세요")
                .font(.caption)
                .foregroundStyle(.tertiary)

            HStack(spacing: 32) {
                ForEach(Array(branch.options.enumerated()), id: \.element.id) { index, option in
                    branchCard(option: option, index: index)
                }
            }
        }
        .padding(24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
    }

    private func branchCard(option: BranchOption, index: Int) -> some View {
        VStack(spacing: 12) {
            ZStack {
                // 진행 링
                Circle()
                    .trim(from: 0, to: CGFloat(dwellProgress[index]))
                    .stroke(.blue.gradient, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))

                // 방향 아이콘
                Image(systemName: option.direction.iconName)
                    .font(.title)
                    .foregroundStyle(
                        selectedIndex == index ? .green.gradient : .blue.gradient
                    )
            }

            Text(option.name)
                .font(.subheadline)
                .fontWeight(.semibold)

            Text(option.difficulty.displayName)
                .font(.caption2)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(difficultyColor(option.difficulty), in: Capsule())

            Text(option.description)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(width: 120)
        }
        .padding()
        .background(
            selectedIndex == index
                ? AnyShapeStyle(.green.opacity(0.1))
                : AnyShapeStyle(.clear),
            in: RoundedRectangle(cornerRadius: 16)
        )
        .hoverEffect()
    }

    private func difficultyColor(_ diff: Difficulty) -> Color {
        switch diff {
        case .beginner: return .green.opacity(0.3)
        case .intermediate: return .orange.opacity(0.3)
        case .advanced: return .red.opacity(0.3)
        }
    }
}
