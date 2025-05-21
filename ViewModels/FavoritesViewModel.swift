import SwiftUI

@MainActor
final class FavoritesViewModel: ObservableObject {
    @Published private(set) var items: [NailDesign] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Кэш избранных для оптимизации
    private var favoriteIds: Set<String> = []
    
    // Ссылка на основной AuthViewModel
    private weak var authViewModel: AuthViewModel?
    
    // Защита от повторных запросов
    private var loadingTask: Task<Void, Never>?
    private var lastLoadedUsername: String?
    
    // Метод для установки ссылки на AuthViewModel
    func setAuthViewModel(_ authVM: AuthViewModel) {
        self.authViewModel = authVM
    }
    
    // Загрузка избранного с сервера
    func loadFavorites() async {
        guard let user = authViewModel?.user else {
            print("Пользователь не найден в authViewModel")
            await MainActor.run {
                items = []
                favoriteIds = []
            }
            return
        }
        
        // Проверяем, не загружаем ли мы уже для этого пользователя
        if lastLoadedUsername == user.username && isLoading {
            print("Уже загружаем избранное для \(user.username), пропускаем")
            return
        }
        
        // Отменяем предыдущую задачу если есть
        loadingTask?.cancel()
        
        print("Загружаем избранное для пользователя: \(user.username)")
        
        // Создаем новую задачу
        loadingTask = Task {
            await MainActor.run {
                isLoading = true
                errorMessage = nil
                lastLoadedUsername = user.username
            }
            
            do {
                let favorites = try await ApiService.shared.fetchFavorites(username: user.username)
                
                // Проверяем, не отменили ли задачу
                if Task.isCancelled {
                    print("Задача загрузки избранного отменена")
                    return
                }
                
                await MainActor.run {
                    items = favorites
                    favoriteIds = Set(favorites.map { $0.id })
                    print("Загружено избранных дизайнов: \(favorites.count)")
                }
            } catch {
                if Task.isCancelled {
                    print("Задача загрузки избранного отменена")
                    return
                }
                
                print("Ошибка загрузки избранного:", error)
                await MainActor.run {
                    // Не показываем ошибку пользователю, просто оставляем пустой список
                    items = []
                    favoriteIds = []
                }
            }
            
            await MainActor.run {
                isLoading = false
            }
        }
        
        await loadingTask?.value
    }
    
    // Добавление/удаление из избранного
    func toggle(_ design: NailDesign) {
        guard let user = authViewModel?.user else {
            print("Пользователь не авторизован в toggle")
            return
        }
        
        print("Переключаем избранное для дизайна \(design.id), пользователь: \(user.username)")
        
        let wasInFavorites = favoriteIds.contains(design.id)
        
        // Оптимистичное обновление UI
        if wasInFavorites {
            favoriteIds.remove(design.id)
            items.removeAll { $0.id == design.id }
        } else {
            favoriteIds.insert(design.id)
            if !items.contains(where: { $0.id == design.id }) {
                items.append(design)
            }
        }
        
        // Отправляем запрос на сервер
        Task {
            do {
                if wasInFavorites {
                    try await ApiService.shared.removeFavorite(id: design.id, username: user.username)
                    print("Дизайн \(design.id) удален из избранного")
                } else {
                    try await ApiService.shared.addFavorite(id: design.id, username: user.username)
                    print("Дизайн \(design.id) добавлен в избранное")
                }
            } catch {
                print("Ошибка при обновлении избранного:", error)
                // Откатываем изменения при ошибке
                await MainActor.run {
                    if wasInFavorites {
                        favoriteIds.insert(design.id)
                        if !items.contains(where: { $0.id == design.id }) {
                            items.append(design)
                        }
                    } else {
                        favoriteIds.remove(design.id)
                        items.removeAll { $0.id == design.id }
                    }
                }
            }
        }
    }
    
    // Проверка, находится ли дизайн в избранном
    func isFavorite(_ design: NailDesign) -> Bool {
        guard authViewModel?.user != nil else { return false }
        return favoriteIds.contains(design.id)
    }
    
    // Очистка избранного при выходе из аккаунта
    func clearFavorites() {
        loadingTask?.cancel()
        loadingTask = nil
        lastLoadedUsername = nil
        items = []
        favoriteIds = []
        errorMessage = nil
        isLoading = false
    }
}
