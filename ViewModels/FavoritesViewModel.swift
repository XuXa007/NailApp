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
    
    // Метод для установки ссылки на AuthViewModel
    func setAuthViewModel(_ authVM: AuthViewModel) {
        self.authViewModel = authVM
    }
    
    // Загрузка избранного с сервера
    func loadFavorites() async {
        guard AuthService.shared.isAuthenticated else {
            print("Пользователь не аутентифицирован")
            await MainActor.run {
                items = []
                favoriteIds = []
            }
            return
        }
        
        loadingTask?.cancel()
        
        print("Загружаем избранное для аутентифицированного пользователя")
        
        loadingTask = Task {
            await MainActor.run {
                isLoading = true
                errorMessage = nil
            }
            
            do {
                let favorites = try await ApiService.shared.fetchFavorites()
                
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
            } catch AuthError.noToken {
                print("Нет токена аутентификации")
                await MainActor.run {
                    authViewModel?.logout()
                }
            } catch {
                if Task.isCancelled {
                    print("Задача загрузки избранного отменена")
                    return
                }
                
                print("Ошибка загрузки избранного:", error)
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    // Не очищаем список при ошибке, оставляем кэш
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
        guard AuthService.shared.isAuthenticated else {
            print("Пользователь не аутентифицирован для toggle")
            authViewModel?.logout()
            return
        }
        
        print("Переключаем избранное для дизайна \(design.id)")
        
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
                    try await ApiService.shared.removeFavorite(id: design.id)
                    print("Дизайн \(design.id) удален из избранного")
                } else {
                    try await ApiService.shared.addFavorite(id: design.id)
                    print("Дизайн \(design.id) добавлен в избранное")
                }
            } catch AuthError.noToken {
                print("Нет токена аутентификации при toggle")
                await MainActor.run {
                    authViewModel?.logout()
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
                    errorMessage = "Ошибка обновления избранного: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // Проверка, находится ли дизайн в избранном
    func isFavorite(_ design: NailDesign) -> Bool {
        guard AuthService.shared.isAuthenticated else { return false }
        return favoriteIds.contains(design.id)
    }
    
    // Очистка избранного при выходе из аккаунта
    func clearFavorites() {
        loadingTask?.cancel()
        loadingTask = nil
        items = []
        favoriteIds = []
        errorMessage = nil
        isLoading = false
        print("Очищено избранное при выходе из аккаунта")
    }
    
    func refreshFavorites() async {
        await loadFavorites()
    }
    
    func clearError() {
        errorMessage = nil
    }
}
