import SwiftUI

extension Color {
    static let eyeJourneyPrimary = Color.blue
    static let eyeJourneySecondary = Color.cyan
    static let eyeJourneyAccent = Color.orange

    static let exerciseSmooth = Color.blue
    static let exerciseSaccade = Color.orange
    static let exerciseVergence = Color.green
    static let exerciseCircular = Color.purple
    static let exerciseNeck = Color.teal

    static func forExerciseType(_ type: ExerciseType) -> Color {
        switch type {
        case .smoothPursuit: return .exerciseSmooth
        case .saccade: return .exerciseSaccade
        case .vergence: return .exerciseVergence
        case .circularTracking: return .exerciseCircular
        case .neckFlexion, .neckRotation, .neckLateralTilt, .neckCircle:
            return .exerciseNeck
        }
    }
}

extension ShapeStyle where Self == AnyShapeStyle {
    static var glassBackground: AnyShapeStyle {
        AnyShapeStyle(.ultraThinMaterial)
    }
}
