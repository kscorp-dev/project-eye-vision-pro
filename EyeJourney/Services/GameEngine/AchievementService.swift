import Foundation

/// 업적/도전 과제 시스템
@Observable
final class AchievementService {
    var unlockedAchievements: [Achievement] = []
    var pendingNotification: Achievement?

    /// 조건 체크 후 업적 해제
    func check(profile: UserProfile, sessions: [ExerciseSession]) {
        for achievement in Achievement.allAchievements {
            guard !unlockedAchievements.contains(where: { $0.id == achievement.id }) else { continue }

            if achievement.condition(profile, sessions) {
                unlockedAchievements.append(achievement)
                pendingNotification = achievement
            }
        }
    }

    func dismissNotification() {
        pendingNotification = nil
    }
}

struct Achievement: Identifiable {
    let id: String
    let title: String
    let titleLocalized: String
    let description: String
    let iconName: String
    let rewardPoints: Int
    let condition: (UserProfile, [ExerciseSession]) -> Bool

    static let allAchievements: [Achievement] = [
        // 스트릭 업적
        Achievement(
            id: "streak_3",
            title: "Getting Started",
            titleLocalized: "시작이 반이다",
            description: "3일 연속 운동 달성",
            iconName: "flame.fill",
            rewardPoints: 100,
            condition: { profile, _ in profile.currentStreak >= 3 }
        ),
        Achievement(
            id: "streak_7",
            title: "One Week Warrior",
            titleLocalized: "일주일의 기적",
            description: "7일 연속 운동 달성",
            iconName: "flame.circle.fill",
            rewardPoints: 300,
            condition: { profile, _ in profile.currentStreak >= 7 }
        ),
        Achievement(
            id: "streak_30",
            title: "Monthly Master",
            titleLocalized: "한 달의 여정",
            description: "30일 연속 운동 달성",
            iconName: "crown.fill",
            rewardPoints: 1000,
            condition: { profile, _ in profile.currentStreak >= 30 }
        ),

        // 세션 업적
        Achievement(
            id: "first_session",
            title: "First Step",
            titleLocalized: "첫 발걸음",
            description: "첫 번째 운동 완료",
            iconName: "figure.walk",
            rewardPoints: 50,
            condition: { profile, _ in profile.totalSessions >= 1 }
        ),
        Achievement(
            id: "sessions_10",
            title: "Regular Traveler",
            titleLocalized: "단골 여행자",
            description: "10회 운동 완료",
            iconName: "airplane",
            rewardPoints: 200,
            condition: { profile, _ in profile.totalSessions >= 10 }
        ),
        Achievement(
            id: "sessions_50",
            title: "World Explorer",
            titleLocalized: "세계 탐험가",
            description: "50회 운동 완료",
            iconName: "globe.americas.fill",
            rewardPoints: 500,
            condition: { profile, _ in profile.totalSessions >= 50 }
        ),

        // 정확도 업적
        Achievement(
            id: "accuracy_90",
            title: "Sharp Eyes",
            titleLocalized: "매의 눈",
            description: "정확도 90% 이상으로 운동 완료",
            iconName: "eye.fill",
            rewardPoints: 200,
            condition: { _, sessions in
                sessions.contains { $0.accuracy >= 0.9 }
            }
        ),
        Achievement(
            id: "perfect_session",
            title: "Perfect Journey",
            titleLocalized: "완벽한 여행",
            description: "정확도 100%로 운동 완료",
            iconName: "star.circle.fill",
            rewardPoints: 500,
            condition: { _, sessions in
                sessions.contains { $0.accuracy >= 0.99 }
            }
        ),

        // 스탬프 업적
        Achievement(
            id: "stamps_4",
            title: "Stamp Collector",
            titleLocalized: "스탬프 수집가",
            description: "4개 지역 스탬프 수집 완료",
            iconName: "stamp.fill",
            rewardPoints: 400,
            condition: { profile, _ in profile.stamps.count >= 4 }
        ),

        // 시간 업적
        Achievement(
            id: "time_1h",
            title: "Dedicated Trainer",
            titleLocalized: "눈 건강 전문가",
            description: "총 운동 시간 1시간 달성",
            iconName: "clock.badge.checkmark",
            rewardPoints: 300,
            condition: { profile, _ in profile.totalExerciseTime >= 3600 }
        ),
    ]
}
