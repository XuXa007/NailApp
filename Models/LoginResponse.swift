import Foundation

struct LoginResponse: Codable {
    let token: String
    let tokenType: String
    let user: UserProfile
}

class AuthToken: ObservableObject {
    @Published var token: String?
    
    private let tokenKey = "jwt_token"
    
    init() {
        loadToken()
    }
    
    func saveToken(_ token: String) {
        self.token = token
        UserDefaults.standard.set(token, forKey: tokenKey)
    }
    
    func loadToken() {
        self.token = UserDefaults.standard.string(forKey: tokenKey)
    }
    
    func clearToken() {
        self.token = nil
        UserDefaults.standard.removeObject(forKey: tokenKey)
    }
    
    var isAuthenticated: Bool {
        return token != nil && !isTokenExpired()
    }
    
    private func isTokenExpired() -> Bool {
        guard let token = token else { return true }
        
        // Простая проверка токена (можно улучшить)
        let parts = token.components(separatedBy: ".")
        guard parts.count == 3 else { return true }
        
        let payload = parts[1]
        guard let data = Data(base64Encoded: addPadding(payload)) else { return true }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let exp = json["exp"] as? Double {
                let expirationDate = Date(timeIntervalSince1970: exp)
                return Date() > expirationDate
            }
        } catch {
            print("Error parsing token: \(error)")
        }
        
        return true
    }
    
    private func addPadding(_ base64: String) -> String {
        let remainder = base64.count % 4
        if remainder > 0 {
            return base64 + String(repeating: "=", count: 4 - remainder)
        }
        return base64
    }
}
