import SwiftUI

/// 업적 목록 뷰
struct AchievementsView: View {
    let unlockedIds: Set<String>

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(Achievement.allAchievements, id: \.id) { achievement in
                    achievementCard(achievement)
                }
            }
            .padding()
        }
        .navigationTitle("업적")
    }

    private func achievementCard(_ achievement: Achievement) -> some View {
        let isUnlocked = unlockedIds.contains(achievement.id)

        return VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? .blue.gradient : .gray.gradient.opacity(0.3))
                    .frame(width: 56, height: 56)

                Image(systemName: achievement.iconName)
                    .font(.title3)
                    .foregroundStyle(isUnlocked ? .white : .secondary)
            }

            Text(achievement.titleLocalized)
                .font(.caption)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            Text(achievement.description)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            if isUnlocked {
                Text("+\(achievement.rewardPoints)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.yellow)
            }
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .opacity(isUnlocked ? 1.0 : 0.5)
    }
}

/// 업적 해제 알림 토스트
struct AchievementToast: View {
    let achievement: Achievement
    let onDismiss: () -> Void

    @State private var offset: CGFloat = -100
    @State private var opacity: Double = 0

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: achievement.iconName)
                .font(.title2)
                .foregroundStyle(.yellow.gradient)

            VStack(alignment: .leading, spacing: 2) {
                Text("업적 달성!")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(achievement.titleLocalized)
                    .font(.subheadline)
                    .fontWeight(.bold)
            }

            Spacer()

            Text("+\(achievement.rewardPoints)")
                .font(.headline)
                .foregroundStyle(.yellow)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
        .offset(y: offset)
        .opacity(opacity)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                offset = 0
                opacity = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.easeOut(duration: 0.3)) {
                    offset = -100
                    opacity = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onDismiss()
                }
            }
        }
    }
}
