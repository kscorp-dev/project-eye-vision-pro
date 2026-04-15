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
    // 눈 운동
    case smoothPursuit = "SmoothPursuit"
    case saccade = "Saccade"
    case vergence = "Vergence"
    case circularTracking = "CircularTracking"
    // 목 운동
    case neckFlexion = "NeckFlexion"
    case neckRotation = "NeckRotation"
    case neckLateralTilt = "NeckLateralTilt"
    case neckCircle = "NeckCircle"

    var displayName: String {
        switch self {
        case .smoothPursuit: return "부드러운 추적"
        case .saccade: return "빠른 시선 이동"
        case .vergence: return "초점 전환"
        case .circularTracking: return "원형 추적"
        case .neckFlexion: return "목 앞뒤 굴곡"
        case .neckRotation: return "목 좌우 회전"
        case .neckLateralTilt: return "목 좌우 기울이기"
        case .neckCircle: return "목 돌리기"
        }
    }

    var iconName: String {
        switch self {
        case .smoothPursuit: return "arrow.right.arrow.left"
        case .saccade: return "bolt.fill"
        case .vergence: return "eye.trianglebadge.exclamationmark"
        case .circularTracking: return "arrow.trianglehead.2.clockwise"
        case .neckFlexion: return "arrow.up.arrow.down"
        case .neckRotation: return "arrow.left.arrow.right.circle"
        case .neckLateralTilt: return "figure.mind.and.body"
        case .neckCircle: return "arrow.trianglehead.clockwise"
        }
    }

    var isNeckExercise: Bool {
        switch self {
        case .neckFlexion, .neckRotation, .neckLateralTilt, .neckCircle:
            return true
        default:
            return false
        }
    }

    var isEyeExercise: Bool {
        !isNeckExercise
    }
}
