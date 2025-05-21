import SwiftUI

@MainActor
final class FavoritesViewModel: ObservableObject {
    @Published private(set) var items: [NailDesign] = []
    @Published var isLoading = false
    
    // Локальное хранилище избранного с использованием UserDefaults
    private let favoritesKey = "user_favorites"
    
    // Получение ID избранных дизайнов для пользователя
    private func getFavoriteIds(for username: String) -> [String] {
        let defaults = UserDefaults.standard
        let allFavorites = defaults.dictionary(forKey: favoritesKey) as? [String: [String]] ?? [:]
        return allFavorites[username] ?? []
    }
    
    // Сохранение ID избранных дизайнов для пользователя
    private func saveFavoriteIds(_ ids: [String], for username: String) {
        let defaults = UserDefaults.standard
        var allFavorites = defaults.dictionary(forKey: favoritesKey) as? [String: [String]] ?? [:]
        allFavorites[username] = ids
        defaults.set(allFavorites, forKey: favoritesKey)
    }
    
    // Загрузка избранного (комбинирует реальные дизайны с локальным списком избранного)
    func loadFavorites() async {
        isLoading = true
        defer { isLoading = false }
        
        guard let username = AuthViewModel.shared.user?.username else {
            items = []
            return
        }
        
        do {
            // Получаем все дизайны с сервера
            let allDesigns = try await ApiService.shared.fetchDesigns()
            
            // Получаем ID избранных дизайнов из локального хранилища
            let favoriteIds = getFavoriteIds(for: username)
            
            // Фильтруем только избранные дизайны
            items = allDesigns.filter { design in
                favoriteIds.contains(design.id)
            }
        } catch {
            print("Ошибка загрузки избранного:", error)
            items = []
        }
    }
    
    // Добавление/удаление из избранного
    func toggle(_ design: NailDesign) {
        guard let username = AuthViewModel.shared.user?.username else { return }
        
        var favoriteIds = getFavoriteIds(for: username)
        
        if favoriteIds.contains(design.id) {
            // Удаляем из избранного
            favoriteIds.removeAll { $0 == design.id }
        } else {
            // Добавляем в избранное
            favoriteIds.append(design.id)
        }
        
        // Сохраняем обновленный список избранного
        saveFavoriteIds(favoriteIds, for: username)
        
        // Обновляем список избранного
        Task {
            await loadFavorites()
        }
    }
    
    // Проверка, находится ли дизайн в избранном
    func isFavorite(_ design: NailDesign) -> Bool {
        guard let username = AuthViewModel.shared.user?.username else { return false }
        let favoriteIds = getFavoriteIds(for: username)
        return favoriteIds.contains(design.id)
    }
}
