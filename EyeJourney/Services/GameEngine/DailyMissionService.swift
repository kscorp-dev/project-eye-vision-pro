import Foundation

/// 일일 미션 시스템
@Observable
final class DailyMissionService {
    var todayMissions: [DailyMission] = []
    var lastRefreshDate: Date?

    init() {
        refreshMissions()
    }

    /// 매일 미션 갱신
    func refreshMissions() {
        let today = Calendar.current.startOfDay(for: Date())
        if let lastRefresh = lastRefreshDate,
           Calendar.current.isDate(lastRefresh, inSameDayAs: today) {
            return // 이미 오늘 갱신됨
        }

        // 시드 기반 랜덤으로 매일 같은 미션 보장
        let daySeed = Int(today.timeIntervalSince1970 / 86400)
        var rng = SeededRNG(seed: UInt64(daySeed))

        let allMissions = DailyMission.missionPool
        todayMissions = allMissions.shuffled(using: &rng).prefix(3).map { mission in
            var m = mission
            m.isCompleted = false
            return m
        }

        lastRefreshDate = today
    }

    /// 미션 완료 체크
    func checkCompletion(sessions: [ExerciseSession], profile: UserProfile) {
        for i in todayMissions.indices {
            if !todayMissions[i].isCompleted {
                todayMissions[i].isCompleted = todayMissions[i].condition(sessions, profile)
            }
        }
    }

    var completedCount: Int {
        todayMissions.filter(\.isCompleted).count
    }

    var allCompleted: Bool {
        !todayMissions.isEmpty && todayMissions.allSatisfy(\.isCompleted)
    }
}

struct DailyMission: Identifiable {
    let id: String
    let title: String
    let description: String
    let iconName: String
    let rewardPoints: Int
    var isCompleted: Bool
    let condition: ([ExerciseSession], UserProfile) -> Bool

    static let missionPool: [DailyMission] = [
        DailyMission(
            id: "daily_1session",
            title: "오늘의 첫 운동",
            description: "아무 운동이나 1회 완료하기",
            iconName: "play.circle.fill",
            rewardPoints: 30,
            isCompleted: false,
            condition: { sessions, _ in
                sessions.contains { Calendar.current.isDateInToday($0.startedAt) }
            }
        ),
        DailyMission(
            id: "daily_3min",
            title: "3분 이상 운동",
            description: "3분 이상 운동하기",
            iconName: "clock.fill",
            rewardPoints: 50,
            isCompleted: false,
            condition: { sessions, _ in
                let todaySessions = sessions.filter { Calendar.current.isDateInToday($0.startedAt) }
                let totalTime = todaySessions.reduce(0) { $0 + $1.duration }
                return totalTime >= 180
            }
        ),
        DailyMission(
            id: "daily_accuracy80",
            title: "정확도 80% 달성",
            description: "정확도 80% 이상으로 운동 완료",
            iconName: "target",
            rewardPoints: 60,
            isCompleted: false,
            condition: { sessions, _ in
                sessions.contains {
                    Calendar.current.isDateInToday($0.startedAt) && $0.accuracy >= 0.8
                }
            }
        ),
        DailyMission(
            id: "daily_combo5",
            title: "콤보 마스터",
            description: "5콤보 이상 달성하기",
            iconName: "flame.fill",
            rewardPoints: 70,
            isCompleted: false,
            condition: { sessions, _ in
                sessions.contains {
                    Calendar.current.isDateInToday($0.startedAt) && $0.totalPoints >= 500
                }
            }
        ),
        DailyMission(
            id: "daily_2sessions",
            title: "두 번째 여행",
            description: "오늘 2회 이상 운동하기",
            iconName: "repeat",
            rewardPoints: 80,
            isCompleted: false,
            condition: { sessions, _ in
                let todayCount = sessions.filter { Calendar.current.isDateInToday($0.startedAt) }.count
                return todayCount >= 2
            }
        ),
        DailyMission(
            id: "daily_streak",
            title: "연속 기록 유지",
            description: "스트릭을 유지하세요",
            iconName: "flame.circle.fill",
            rewardPoints: 40,
            isCompleted: false,
            condition: { _, profile in profile.currentStreak >= 2 }
        ),
    ]
}

/// 시드 기반 랜덤 생성기 (매일 같은 미션 보장)
struct SeededRNG: RandomNumberGenerator {
    var state: UInt64

    init(seed: UInt64) {
        self.state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
}
