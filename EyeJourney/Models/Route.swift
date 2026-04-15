import Foundation
import CoreLocation
import SwiftData

@Model
final class Route {
    var id: UUID
    var regionName: String
    var regionNameLocalized: String
    var difficulty: Difficulty
    var estimatedDuration: TimeInterval
    var exerciseTypes: [ExerciseType]
    var thumbnailName: String
    var isUnlocked: Bool
    var isCompleted: Bool

    @Relationship(deleteRule: .cascade)
    var waypoints: [Waypoint]

    init(
        regionName: String,
        regionNameLocalized: String,
        difficulty: Difficulty,
        estimatedDuration: TimeInterval,
        exerciseTypes: [ExerciseType],
        thumbnailName: String,
        isUnlocked: Bool = false
    ) {
        self.id = UUID()
        self.regionName = regionName
        self.regionNameLocalized = regionNameLocalized
        self.difficulty = difficulty
        self.estimatedDuration = estimatedDuration
        self.exerciseTypes = exerciseTypes
        self.thumbnailName = thumbnailName
        self.isUnlocked = isUnlocked
        self.isCompleted = false
        self.waypoints = []
    }
}

enum Difficulty: String, Codable, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"

    var displayName: String {
        switch self {
        case .beginner: return "초급"
        case .intermediate: return "중급"
        case .advanced: return "고급"
        }
    }

    var color: String {
        switch self {
        case .beginner: return "green"
        case .intermediate: return "orange"
        case .advanced: return "red"
        }
    }
}

enum ExerciseType: String, Codable, CaseIterable {
    case smoothPursuit = "SmoothPursuit"
    case saccade = "Saccade"
    case vergence = "Vergence"
    case circularTracking = "CircularTracking"

    var displayName: String {
        switch self {
        case .smoothPursuit: return "부드러운 추적"
        case .saccade: return "빠른 시선 이동"
        case .vergence: return "초점 전환"
        case .circularTracking: return "원형 추적"
        }
    }

    var iconName: String {
        switch self {
        case .smoothPursuit: return "arrow.right.arrow.left"
        case .saccade: return "bolt.fill"
        case .vergence: return "eye.trianglebadge.exclamationmark"
        case .circularTracking: return "arrow.trianglehead.2.clockwise"
        }
    }
}
