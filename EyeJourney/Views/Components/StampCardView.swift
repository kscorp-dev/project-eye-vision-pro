import SwiftUI

/// 여행 스탬프 카드 컴포넌트
struct StampCardView: View {
    let stamp: Stamp

    @State private var isHovered = false

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(.blue.gradient.opacity(0.2))
                    .frame(width: 64, height: 64)

                Image(systemName: stamp.iconName)
                    .font(.title2)
                    .foregroundStyle(.blue.gradient)
            }
            .scaleEffect(isHovered ? 1.1 : 1.0)

            Text(stamp.regionNameLocalized)
                .font(.caption2)
                .fontWeight(.medium)
                .lineLimit(1)

            Text(stamp.earnedAt.formatted(date: .abbreviated, time: .omitted))
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .hoverEffect()
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
}
