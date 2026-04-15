import SwiftUI
import SwiftData

@Observable
final class HomeViewModel {
    var routes: [Route] = []
    var currentStreak: Int = 0
    var hasExercisedToday: Bool = false
    var selectedProgram: ExerciseProgram?
    var showExercise = false

    let dailyMissions = DailyMissionService()

    var recommendedProgram: ExerciseProgram {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<10: return .morningStretch
        case 10..<14: return .lunchRefresh
        case 14..<20: return .fullCourse
        default: return .nightRelax
        }
    }

    func loadData(modelContext: ModelContext) {
        // 프로필 로드
        let profileDescriptor = FetchDescriptor<UserProfile>()
        if let profile = try? modelContext.fetch(profileDescriptor).first {
            currentStreak = profile.currentStreak
            hasExercisedToday = profile.hasExercisedToday
        }

        // 루트 로드
        let routeDescriptor = FetchDescriptor<Route>(
            sortBy: [SortDescriptor(\.regionName)]
        )
        let savedRoutes = (try? modelContext.fetch(routeDescriptor)) ?? []
        routes = savedRoutes.isEmpty ? Self.sampleRoutes : savedRoutes

        // 세션 로드 후 미션 체크
        let sessionDescriptor = FetchDescriptor<ExerciseSession>(
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )
        if let profile = try? modelContext.fetch(profileDescriptor).first,
           let sessions = try? modelContext.fetch(sessionDescriptor) {
            dailyMissions.checkCompletion(sessions: sessions, profile: profile)
        }
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
