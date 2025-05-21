import Foundation

@MainActor
class AuthViewModel: ObservableObject {
    @Published var user: UserProfile? = nil
    @Published var isLoading = false
    
    func login(username: String, password: String) async {
        isLoading = true
        defer { isLoading = false }
        do { user = try await AuthService.shared.login(username: username, password: password) }
        catch { print(error) }
    }
    
    func registerClient(username: String, email: String, password: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            user = try await AuthService.shared.registerClient(username: username, email: email, password: password)
        }
        catch { print(error) }
    }
    
    func registerMaster(username: String, email: String, password: String, salonName: String, address: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            user = try await AuthService.shared.registerMaster(username: username, email: email, password: password, salonName: salonName, address: address)
        }
        catch { print(error) }
    }
    
    func logout() {
        user = nil
    }
}
