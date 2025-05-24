import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var user: UserProfile? = nil
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Ссылка на FavoritesViewModel для очистки избранного
    private weak var favoritesViewModel: FavoritesViewModel?
    
    init() {
        // Проверяем, есть ли сохраненный пользователь при запуске
        if AuthService.shared.isAuthenticated {
            user = AuthService.shared.currentUser
        }
    }
    
    func setFavoritesViewModel(_ favVM: FavoritesViewModel) {
        self.favoritesViewModel = favVM
    }
    
    
    func login(username: String, password: String) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let loggedInUser = try await AuthService.shared.login(username: username, password: password)
            await MainActor.run {
                self.user = loggedInUser
                self.isLoading = false
                print("Успешный вход: \(loggedInUser.username)")
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
                print("Ошибка входа: \(error.localizedDescription)")
            }
        }
    }
    
    func registerClient(username: String, email: String, password: String) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let registeredUser = try await AuthService.shared.registerClient(
                username: username,
                email: email,
                password: password
            )
            await MainActor.run {
                self.user = registeredUser
                self.isLoading = false
                print("Успешная регистрация клиента: \(registeredUser.username)")
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
                print("Ошибка регистрации клиента: \(error.localizedDescription)")
            }
        }
    }
    
    func registerMaster(username: String, email: String, password: String,
                       salonName: String, address: String) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let registeredUser = try await AuthService.shared.registerMaster(
                username: username,
                email: email,
                password: password,
                salonName: salonName,
                address: address
            )
            await MainActor.run {
                self.user = registeredUser
                self.isLoading = false
                print("Успешная регистрация мастера: \(registeredUser.username)")
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
                print("Ошибка регистрации мастера: \(error.localizedDescription)")
            }
        }
    }
    
    func refreshProfile() async {
        guard AuthService.shared.isAuthenticated else { return }
        
        do {
            let updatedUser = try await AuthService.shared.getProfile()
            await MainActor.run {
                self.user = updatedUser
            }
        } catch {
            print("Ошибка обновления профиля: \(error.localizedDescription)")
            await MainActor.run {
                logout()
            }
        }
    }
    
    func logout() {
        AuthService.shared.logout()
        user = nil
        
        favoritesViewModel?.clearFavorites()
        print("Выполнен выход из аккаунта")
    }
        
    func loginAsClient() {
        // Создаем демо-пользователя для тестирования UI
        user = UserProfile(
            id: "demo-client",
            username: "demo_client",
            email: "client@example.com",
            role: .client
        )
        print("Демо-вход как клиент: \(user?.username ?? "unknown")")
    }
    
    func loginAsMaster() {
        user = UserProfile(
            id: "demo-master",
            username: "demo_master",
            email: "master@example.com",
            role: .master,
            salonName: "Демо Салон",
            address: "ул. Пушкина, д. 10"
        )
        print("Демо-вход как мастер: \(user?.username ?? "unknown")")
    }
    
    
    func login(username: String, password: String) {
        Task {
            await login(username: username, password: password)
        }
    }
    
    func registerClientSync(username: String, email: String, password: String) {
        Task {
            await registerClient(username: username, email: email, password: password)
        }
    }
    
    func registerMasterSync(username: String, email: String, password: String,
                           salonName: String, address: String) {
        Task {
            await registerMaster(username: username, email: email, password: password,
                               salonName: salonName, address: address)
        }
    }
    
    
    func clearError() {
        errorMessage = nil
    }
    
    var isAuthenticated: Bool {
        return user != nil && AuthService.shared.isAuthenticated
    }
    
    var isMaster: Bool {
        return user?.role == .master
    }
}
