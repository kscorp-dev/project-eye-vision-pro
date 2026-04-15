import SwiftUI

/// 보너스 이벤트 발생 시 오버레이
struct EventOverlayView: View {
    let event: GameEvent
    let onComplete: () -> Void

    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: event.type.iconName)
                .font(.system(size: 50))
                .foregroundStyle(eventColor.gradient)

            Text(event.type.rawValue)
                .font(.title3)
                .fontWeight(.bold)

            Text(event.type.bonusText)
                .font(.title2)
                .fontWeight(.heavy)
                .foregroundStyle(.yellow.gradient)

            Text(eventDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("받기") {
                onComplete()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(32)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
        .scaleEffect(scale)
        .opacity(opacity)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }

    private var eventColor: Color {
        switch event.type {
        case .bonusAnimal: return .orange
        case .speedChallenge: return .red
        case .hiddenStamp: return .purple
        }
    }

    private var eventDescription: String {
        switch event.type {
        case .bonusAnimal: return "야생 동물을 발견했습니다!"
        case .speedChallenge: return "빠른 추적에 성공했습니다!"
        case .hiddenStamp: return "숨겨진 스탬프를 찾았습니다!"
        }
    }
}
