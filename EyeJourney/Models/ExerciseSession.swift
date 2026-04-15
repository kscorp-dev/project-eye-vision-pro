import Foundation
import SwiftData

@Model
final class ExerciseSession {
    var id: UUID
    var routeId: UUID
    var startedAt: Date
    var completedAt: Date?
    var accuracy: Double
    var averageReactionTime: TimeInterval
    var gazeDistance: Double
    var totalPoints: Int
    var exerciseResults: [ExerciseTypeResult]

    init(routeId: UUID) {
        self.id = UUID()
        self.routeId = routeId
        self.startedAt = Date()
        self.accuracy = 0
        self.averageReactionTime = 0
        self.gazeDistance = 0
        self.totalPoints = 0
        self.exerciseResults = []
    }

    var duration: TimeInterval {
        guard let completedAt else { return Date().timeIntervalSince(startedAt) }
        return completedAt.timeIntervalSince(startedAt)
    }

    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var accuracyPercentage: String {
        String(format: "%.1f%%", accuracy * 100)
    }
}

struct ExerciseTypeResult: Codable {
    var type: ExerciseType
    var accuracy: Double
    var reactionTime: TimeInterval
    var pointsEarned: Int
}
