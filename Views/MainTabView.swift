import SwiftUI

struct MainTabView: View {
    @StateObject private var authVM = AuthViewModel()
    @StateObject private var designsVM = DesignsViewModel()
    @StateObject private var favVM = FavoritesViewModel()
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        let gradientImage = UIImage.gradientImage(
            colors: [UIColor.purple.withAlphaComponent(0.3),
                     UIColor.blue.withAlphaComponent(0.3)],
            size: UIScreen.main.bounds.size
        )
        appearance.backgroundImage = gradientImage
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView {
            // Каталог дизайнов (доступен всем)
            NavigationStack {
                DesignsView()
                    .environmentObject(designsVM)
                    .environmentObject(favVM)
            }
            .tabItem {
                Label("Каталог", systemImage: "square.grid.2x2.fill")
            }
            
            // Избранное (для всех пользователей)
            NavigationStack {
                FavoritesView()
                    .environmentObject(favVM)
            }
            .tabItem {
                Label("Избранное", systemImage: "heart.fill")
            }
            
            if let user = authVM.user, user.role == .master {
                NavigationStack {
                    MasterDashboardView()
                        .environmentObject(authVM)
                }
                .tabItem {
                    Label("Мои дизайны", systemImage: "plus.app.fill")
                }
            }
            

            
            // Профиль пользователя (для всех)
            NavigationStack {
                ProfileView()
                    .environmentObject(authVM)
                    .environmentObject(favVM)
            }
            .tabItem {
                Label("Профиль", systemImage: "person.crop.circle.fill")
            }
        }
        .environmentObject(authVM)
    }
}
