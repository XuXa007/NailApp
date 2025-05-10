import Foundation

class AuthService {
    static let shared = AuthService()
    private init() {}

    func login(username: String, password: String) async throws -> UserProfile {
        // Fake auth
        return UserProfile(id: .init(), username: username, email: "\(username)@mail.com")
    }

    func register(username: String, email: String, password: String) async throws -> UserProfile {
        return UserProfile(id: .init(), username: username, email: email)
    }
}
