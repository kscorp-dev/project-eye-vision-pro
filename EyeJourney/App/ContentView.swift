import SwiftUI

struct ContentView: View {
    @Environment(AppModel.self) private var appModel
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        if !hasSeenOnboarding {
            OnboardingView {
                withAnimation { hasSeenOnboarding = true }
            }
        } else {
            tabContent
        }
    }

    private var tabContent: some View {
        @Bindable var appModel = appModel

        return TabView(selection: $appModel.selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(AppModel.Tab.home)

            MapExplorerView()
                .tabItem {
                    Label("Explore", systemImage: "map.fill")
                }
                .tag(AppModel.Tab.explore)

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(AppModel.Tab.profile)
        }
    }
}
