import SwiftUI
import simd

/// 시선을 유도하는 가이드 포인트 UI
struct GuidePointView: View {
    let position: SIMD3<Float>
    let progress: Float     // dwell progress (0.0 ~ 1.0)
    let guideType: GuideType

    @State private var isAnimating = false
    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            // 외곽 링 (dwell 진행도)
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(progressColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .frame(width: 60, height: 60)
                .rotationEffect(.degrees(-90))

            // 가이드 아이콘
            Image(systemName: guideType.systemImageName)
                .font(.title2)
                .foregroundStyle(guideColor.gradient)
                .scaleEffect(pulseScale)

            // 파티클 이펙트 (활성화 시)
            if progress > 0 {
                ForEach(0..<6, id: \.self) { i in
                    Circle()
                        .fill(guideColor.opacity(0.5))
                        .frame(width: 4, height: 4)
                        .offset(particleOffset(index: i))
                        .opacity(isAnimating ? 0 : 0.8)
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulseScale = 1.2
                isAnimating = true
            }
        }
        .position(
            x: CGFloat(position.x) * 500 + 500,
            y: CGFloat(-position.y) * 500 + 400
        )
    }

    private var guideColor: Color {
        switch guideType {
        case .butterfly: return .purple
        case .firefly: return .yellow
        case .star: return .white
        case .petal: return .pink
        case .bird: return .cyan
        }
    }

    private var progressColor: Color {
        if progress >= 1.0 {
            return .green
        } else if progress > 0.5 {
            return .orange
        }
        return .blue
    }

    private func particleOffset(index: Int) -> CGSize {
        let angle = Double(index) / 6.0 * .pi * 2
        let radius: CGFloat = isAnimating ? 30 : 15
        return CGSize(
            width: cos(angle) * radius,
            height: sin(angle) * radius
        )
    }
}

extension GuideType {
    var systemImageName: String {
        switch self {
        case .butterfly: return "ladybug.fill"
        case .firefly: return "sparkle"
        case .star: return "star.fill"
        case .petal: return "leaf.fill"
        case .bird: return "bird.fill"
        }
    }
}
