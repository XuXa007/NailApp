import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var selection: Tab = .designs
    enum Tab { case designs, profile }

    var body: some View {
        TabView(selection: $selection) {
            NavigationStack {
                DesignsView()
            }
            .tabItem { Label("Designs", systemImage: "square.grid.2x2") }
            .tag(Tab.designs)

            NavigationStack {
                ProfileView()
            }
            .tabItem { Label("Profile", systemImage: "person.crop.circle") }
            .tag(Tab.profile)
        }
    }
}
