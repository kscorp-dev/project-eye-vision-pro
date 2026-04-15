import Foundation
import SwiftData

@Model
final class UserProfile {
    var id: UUID
    var nickname: String
    var totalExerciseTime: TimeInterval
    var totalSessions: Int
    var currentStreak: Int
    var longestStreak: Int
    var lastExerciseDate: Date?

    @Relationship(deleteRule: .cascade)
    var stamps: [Stamp]

    init(nickname: String = "Traveler") {
        self.id = UUID()
        self.nickname = nickname
        self.totalExerciseTime = 0
        self.totalSessions = 0
        self.currentStreak = 0
        self.longestStreak = 0
        self.stamps = []
    }

    /// 오늘 운동 완료 여부
    var hasExercisedToday: Bool {
        guard let lastDate = lastExerciseDate else { return false }
        return Calendar.current.isDateInToday(lastDate)
    }

    /// 스트릭 업데이트
    func updateStreak() {
        if hasExercisedToday { return }

        let calendar = Calendar.current
        if let lastDate = lastExerciseDate,
           calendar.isDateInYesterday(lastDate) {
            currentStreak += 1
        } else {
            currentStreak = 1
        }

        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }

        lastExerciseDate = Date()
    }
}

@Model
final class Stamp {
    var id: UUID
    var regionName: String
    var regionNameLocalized: String
    var iconName: String
    var earnedAt: Date
    var routeId: UUID

    @Relationship(deleteRule: .noAction, inverse: \UserProfile.stamps)
    var userProfile: UserProfile?

    init(
        regionName: String,
        regionNameLocalized: String,
        iconName: String,
        routeId: UUID
    ) {
        self.id = UUID()
        self.regionName = regionName
        self.regionNameLocalized = regionNameLocalized
        self.iconName = iconName
        self.earnedAt = Date()
        self.routeId = routeId
    }
}
