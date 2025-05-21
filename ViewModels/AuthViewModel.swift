import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    static let shared = AuthViewModel()
    
    @Published var user: UserProfile? = nil
    @Published var isLoading = false
    
    // Ссылка на FavoritesViewModel для очистки избранного
    private weak var favoritesViewModel: FavoritesViewModel?
    
    // Метод для установки ссылки на FavoritesViewModel
    func setFavoritesViewModel(_ favVM: FavoritesViewModel) {
        self.favoritesViewModel = favVM
    }
    
    // Демо-вход для клиента
    func loginAsClient() {
        user = UserProfile(
            id: "demo-client",
            username: "demo_client",
            email: "client@example.com",
            role: .client
        )
        print("Выполнен вход как клиент: \(user?.username ?? "unknown")")
    }
    
    // Демо-вход для мастера
    func loginAsMaster() {
        user = UserProfile(
            id: "demo-master",
            username: "demo_master",
            email: "master@example.com",
            role: .master,
            salonName: "Студия Nail Art",
            address: "ул. Пушкина, д. 10"
        )
        print("Выполнен вход как мастер: \(user?.username ?? "unknown")")
    }
    
    func logout() {
        user = nil
        // Очищаем избранное при выходе
        favoritesViewModel?.clearFavorites()
        print("Выполнен выход из аккаунта")
    }
    
    // Имитация входа
    func login(username: String, password: String) {
        isLoading = true
        
        // Имитация задержки
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            // Для демонстрации просто проверяем имя пользователя
            if username.lowercased() == "client" {
                self.loginAsClient()
            } else if username.lowercased() == "master" {
                self.loginAsMaster()
            } else {
                // По умолчанию входим как клиент
                self.loginAsClient()
            }
            
            self.isLoading = false
        }
    }
    
    // ВАЖНЫЕ НОВЫЕ МЕТОДЫ: синхронные версии регистрации
    func registerClientSync(username: String, email: String, password: String) {
        isLoading = true
        
        // Имитация задержки
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            
            // Для демонстрации успешно регистрируем клиента
            self.loginAsClient()
            self.isLoading = false
        }
    }
    
    func registerMasterSync(username: String, email: String, password: String, salonName: String, address: String) {
        isLoading = true
        
        // Имитация задержки
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            
            // Создаем пользователя-мастера с указанными данными
            self.user = UserProfile(
                id: "demo-master",
                username: username,
                email: email,
                role: .master,
                salonName: salonName,
                address: address
            )
            
            self.isLoading = false
        }
    }
    
    // Асинхронные методы для совместимости - они просто вызывают синхронные
    func registerClient(username: String, email: String, password: String) async {
        registerClientSync(username: username, email: email, password: password)
    }
    
    func registerMaster(username: String, email: String, password: String, salonName: String, address: String) async {
        registerMasterSync(username: username, email: email, password: password, salonName: salonName, address: address)
    }
}
