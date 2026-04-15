import SwiftUI

struct ContentView: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        @Bindable var appModel = appModel

        TabView(selection: $appModel.selectedTab) {
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
