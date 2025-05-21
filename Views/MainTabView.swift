import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var designsVM: DesignsViewModel
    @EnvironmentObject var favVM: FavoritesViewModel
    
    var body: some View {
        TabView {
            // Catalog (available for everyone)
            NavigationStack {
                DesignsView()
            }
            .tabItem {
                Label("Каталог", systemImage: "square.grid.2x2.fill")
            }
            
            NavigationStack {
                FavoritesView()
            }
            .tabItem {
                Label("Избранное", systemImage: "heart.fill")
            }
            
            // Master dashboard (only for masters)
            if let user = authVM.user, user.role == .master {
                NavigationStack {
                    MasterDashboardView()
                }
                .tabItem {
                    Label("Мои дизайны", systemImage: "scissors")
                }
            }
            
            // Profile (available for everyone)
            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("Профиль", systemImage: "person.crop.circle.fill")
            }
        }
    }
}
