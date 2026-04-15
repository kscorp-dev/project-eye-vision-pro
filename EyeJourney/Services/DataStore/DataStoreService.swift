import SwiftData
import Foundation

/// SwiftData 기반 로컬 데이터 저장/조회 서비스
final class DataStoreService {
    let modelContainer: ModelContainer
    let modelContext: ModelContext

    init() throws {
        let schema = Schema([
            UserProfile.self,
            Route.self,
            Waypoint.self,
            ExerciseSession.self,
            Stamp.self,
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: false)
        self.modelContainer = try ModelContainer(for: schema, configurations: config)
        self.modelContext = ModelContext(modelContainer)
    }

    // MARK: - UserProfile

    func getOrCreateProfile() -> UserProfile {
        let descriptor = FetchDescriptor<UserProfile>()
        if let existing = try? modelContext.fetch(descriptor).first {
            return existing
        }
        let profile = UserProfile()
        modelContext.insert(profile)
        try? modelContext.save()
        return profile
    }

    // MARK: - Routes

    func fetchRoutes() -> [Route] {
        let descriptor = FetchDescriptor<Route>(
            sortBy: [SortDescriptor(\.regionName)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func seedDefaultRoutes() {
        let existingRoutes = fetchRoutes()
        guard existingRoutes.isEmpty else { return }

        let defaultRoutes = [
            Route(
                regionName: "Jeju Olle Trail",
                regionNameLocalized: "제주 올레길",
                difficulty: .beginner,
                estimatedDuration: 180,
                exerciseTypes: [.smoothPursuit, .saccade],
                thumbnailName: "jeju_thumbnail",
                isUnlocked: true
            ),
            Route(
                regionName: "Swiss Alps",
                regionNameLocalized: "스위스 알프스",
                difficulty: .intermediate,
                estimatedDuration: 300,
                exerciseTypes: [.saccade, .vergence],
                thumbnailName: "swiss_thumbnail"
            ),
            Route(
                regionName: "Santorini",
                regionNameLocalized: "그리스 산토리니",
                difficulty: .intermediate,
                estimatedDuration: 300,
                exerciseTypes: [.saccade, .circularTracking],
                thumbnailName: "santorini_thumbnail"
            ),
            Route(
                regionName: "Iceland Aurora",
                regionNameLocalized: "아이슬란드 오로라",
                difficulty: .beginner,
                estimatedDuration: 180,
                exerciseTypes: [.circularTracking, .smoothPursuit],
                thumbnailName: "iceland_thumbnail"
            ),
        ]

        for route in defaultRoutes {
            modelContext.insert(route)
        }
        try? modelContext.save()
    }

    // MARK: - ExerciseSession

    func saveSession(_ session: ExerciseSession) {
        modelContext.insert(session)
        try? modelContext.save()
    }

    func fetchRecentSessions(limit: Int = 10) -> [ExerciseSession] {
        var descriptor = FetchDescriptor<ExerciseSession>(
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    // MARK: - Stats

    func totalExerciseTime() -> TimeInterval {
        let sessions = fetchRecentSessions(limit: 1000)
        return sessions.reduce(0) { $0 + $1.duration }
    }

    func weeklySessionCount() -> Int {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let predicate = #Predicate<ExerciseSession> { $0.startedAt >= weekAgo }
        let descriptor = FetchDescriptor<ExerciseSession>(predicate: predicate)
        return (try? modelContext.fetchCount(descriptor)) ?? 0
    }
}
