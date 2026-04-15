import SwiftUI

@Observable
final class HomeViewModel {
    var routes: [Route] = []
    var currentStreak: Int = 0
    var hasExercisedToday: Bool = false
    var selectedProgram: ExerciseProgram?
    var showExercise = false

    var recommendedProgram: ExerciseProgram {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<10: return .morningStretch
        case 10..<14: return .lunchRefresh
        case 14..<20: return .fullCourse
        default: return .nightRelax
        }
    }

    init() {
        loadData()
    }

    func loadData() {
        // SwiftData에서 루트 및 프로필 로드
        // 프로토타입에서는 더미 데이터 사용
        routes = Self.sampleRoutes
        currentStreak = 3
    }

    func startExercise() {
        let program = selectedProgram ?? recommendedProgram
        selectedProgram = program
        showExercise = true
    }

    // MARK: - Sample Data

    static let sampleRoutes: [Route] = [
        Route(
            regionName: "Jeju Olle Trail",
            regionNameLocalized: "제주 올레길",
            difficulty: .beginner,
            estimatedDuration: 180,
            exerciseTypes: [.smoothPursuit, .saccade],
            thumbnailName: "jeju",
            isUnlocked: true
        ),
        Route(
            regionName: "Swiss Alps",
            regionNameLocalized: "스위스 알프스",
            difficulty: .intermediate,
            estimatedDuration: 300,
            exerciseTypes: [.saccade, .vergence],
            thumbnailName: "swiss"
        ),
        Route(
            regionName: "Santorini",
            regionNameLocalized: "그리스 산토리니",
            difficulty: .intermediate,
            estimatedDuration: 300,
            exerciseTypes: [.saccade, .circularTracking],
            thumbnailName: "santorini"
        ),
        Route(
            regionName: "Iceland Aurora",
            regionNameLocalized: "아이슬란드 오로라",
            difficulty: .beginner,
            estimatedDuration: 180,
            exerciseTypes: [.circularTracking, .smoothPursuit],
            thumbnailName: "iceland"
        ),
    ]
}
