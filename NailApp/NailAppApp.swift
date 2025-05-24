import SwiftUI

@main
struct NailAppApp: App {
    @StateObject private var authVM = AuthViewModel()
    @StateObject private var designsVM = DesignsViewModel()
    @StateObject private var favVM = FavoritesViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(authVM)
                .environmentObject(designsVM)
                .environmentObject(favVM)
                .onAppear {
                    setupViewModels()
                }
                .task {
                    // Проверяем токен при запуске приложения
                    await refreshUserProfile()
                }
        }
    }
    
    private func setupViewModels() {
        // Связываем ViewModels
        favVM.setAuthViewModel(authVM)
        authVM.setFavoritesViewModel(favVM)
        
        print("ViewModels связаны")
    }
    
    private func refreshUserProfile() async {
        if AuthService.shared.isAuthenticated {
            await authVM.refreshProfile()
            
            // Если пользователь все еще аутентифицирован, загружаем избранное
            if authVM.user != nil {
                await favVM.loadFavorites()
            }
        }
    }
}
