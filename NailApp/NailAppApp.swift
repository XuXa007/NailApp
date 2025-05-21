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
                    // Связываем FavoritesViewModel с AuthViewModel
                    favVM.setAuthViewModel(authVM)
                }
        }
    }
}
