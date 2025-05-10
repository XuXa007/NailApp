// MainTabView.swift
import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Вкладка "Дизайны"
            NavigationView {
                DesignsHomeView()
            }
            .tabItem {
                Image(systemName: "paintpalette.fill")
                Text("Дизайны")
            }
            .tag(0)
            
            // Вкладка "Примерка"
            NavigationView {
                ARTryOnView()
            }
            .tabItem {
                Image(systemName: "camera.fill")
                Text("Примерка")
            }
            .tag(1)
            
            // Вкладка "Избранное"
            NavigationView {
                FavoritesView()
            }
            .tabItem {
                Image(systemName: "heart.fill")
                Text("Избранное")
            }
            .tag(2)
            
            // Вкладка "Профиль"
            NavigationView {
                ProfileView()
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("Профиль")
            }
            .tag(3)
        }
        .accentColor(.pink) // Цвет акцента для приложения о маникюре
    }
}
