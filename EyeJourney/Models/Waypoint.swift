import Foundation
import SwiftData
import simd

@Model
final class Waypoint {
    var id: UUID
    var latitude: Double
    var longitude: Double
    var altitude: Double
    var guideType: GuideType
    var exercisePattern: ExerciseType
    var orderIndex: Int
    var dwellTime: TimeInterval
    var hasBranch: Bool
    var branchOptionNames: [String]

    @Relationship(deleteRule: .noAction, inverse: \Route.waypoints)
    var route: Route?

    init(
        latitude: Double,
        longitude: Double,
        altitude: Double = 0,
        guideType: GuideType = .firefly,
        exercisePattern: ExerciseType = .smoothPursuit,
        orderIndex: Int,
        dwellTime: TimeInterval = 1.0,
        hasBranch: Bool = false,
        branchOptionNames: [String] = []
    ) {
        self.id = UUID()
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        self.guideType = guideType
        self.exercisePattern = exercisePattern
        self.orderIndex = orderIndex
        self.dwellTime = dwellTime
        self.hasBranch = hasBranch
        self.branchOptionNames = branchOptionNames
    }

    /// 3D 공간에서의 위치 (RealityKit용)
    var position3D: SIMD3<Float> {
        SIMD3<Float>(
            Float(longitude * 0.01),
            Float(altitude * 0.001),
            Float(latitude * -0.01)
        )
    }
}

enum GuideType: String, Codable, CaseIterable {
    case butterfly = "Butterfly"
    case firefly = "Firefly"
    case star = "Star"
    case petal = "Petal"
    case bird = "Bird"

    var displayName: String {
        switch self {
        case .butterfly: return "나비"
        case .firefly: return "반딧불"
        case .star: return "별"
        case .petal: return "꽃잎"
        case .bird: return "새"
        }
    }

    var particleColor: String {
        switch self {
        case .butterfly: return "purple"
        case .firefly: return "yellow"
        case .star: return "white"
        case .petal: return "pink"
        case .bird: return "blue"
        }
    }

    var systemImageName: String {
        switch self {
        case .butterfly: return "leaf.fill"
        case .firefly: return "sparkle"
        case .star: return "star.fill"
        case .petal: return "camera.macro"
        case .bird: return "bird.fill"
        }
    }
}
