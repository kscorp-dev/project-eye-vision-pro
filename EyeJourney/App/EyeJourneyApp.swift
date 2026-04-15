import SwiftUI
import SwiftData

@main
struct EyeJourneyApp: App {
    @State private var appModel = AppModel()
    @State private var soundService = SoundService()
    @State private var achievementService = AchievementService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
                .environment(soundService)
                .environment(achievementService)
        }
        .modelContainer(for: [
            UserProfile.self,
            Route.self,
            Waypoint.self,
            ExerciseSession.self,
            Stamp.self,
        ])

        ImmersiveSpace(id: "ExerciseSpace") {
            ExerciseImmersiveView()
                .environment(appModel)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
