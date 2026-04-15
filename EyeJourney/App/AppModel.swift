import SwiftUI

@Observable
class AppModel {
    var selectedTab: Tab = .home
    var isExerciseActive = false
    var isImmersiveSpaceOpen = false

    enum Tab: String, CaseIterable {
        case home = "Home"
        case explore = "Explore"
        case profile = "Profile"
    }
}
