import Foundation

struct AuthResponse: Codable {
    let token: String
    let type: String
    let user: UserProfile
}

enum AuthError: Error, LocalizedError {
    case noToken
    case invalidCredentials
    case userAlreadyExists
    case networkError
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .noToken:
            return "Токен аутентификации отсутствует"
        case .invalidCredentials:
            return "Неверные учетные данные"
        case .userAlreadyExists:
            return "Пользователь уже существует"
        case .networkError:
            return "Ошибка сети"
        case .invalidResponse:
            return "Неверный ответ сервера"
        }
    }
}

class AuthService {
    static let shared = AuthService()
    private init() {}
    
    private var baseURL: URL {
        guard let url = URL(string: Config.baseURL) else {
            fatalError("Base URL is not a valid URL")
        }
        return url
    }
    
    private let tokenKey = "jwt_token"
    private let userKey = "current_user"
    
    var currentToken: String? {
        get {
            return UserDefaults.standard.string(forKey: tokenKey)
        }
        set {
            if let token = newValue {
                UserDefaults.standard.set(token, forKey: tokenKey)
            } else {
                UserDefaults.standard.removeObject(forKey: tokenKey)
            }
        }
    }
    
    var currentUser: UserProfile? {
        get {
            guard let data = UserDefaults.standard.data(forKey: userKey) else { return nil }
            return try? JSONDecoder().decode(UserProfile.self, from: data)
        }
        set {
            if let user = newValue {
                let data = try? JSONEncoder().encode(user)
                UserDefaults.standard.set(data, forKey: userKey)
            } else {
                UserDefaults.standard.removeObject(forKey: userKey)
            }
        }
    }
    
    var isAuthenticated: Bool {
        return currentToken != nil && currentUser != nil
    }
    
    func logout() {
        currentToken = nil
        currentUser = nil
        print("Пользователь вышел из системы")
    }
    
    
    func login(username: String, password: String) async throws -> UserProfile {
        let url = baseURL.appendingPathComponent("api/auth/login")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["username": username, "password": password]
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AuthError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                
                // Сохраняем токен и пользователя
                currentToken = authResponse.token
                currentUser = authResponse.user
                
                print("Успешный вход пользователя: \(authResponse.user.username)")
                return authResponse.user
                
            case 401:
                throw AuthError.invalidCredentials
                
            case 400...499:
                if let errorData = try? JSONDecoder().decode([String: String].self, from: data),
                   let message = errorData["message"] {
                    throw NSError(domain: "AuthError", code: httpResponse.statusCode,
                                userInfo: [NSLocalizedDescriptionKey: message])
                }
                throw AuthError.invalidCredentials
                
            default:
                throw AuthError.networkError
            }
            
        } catch let error as AuthError {
            throw error
        } catch {
            print("Ошибка входа: \(error.localizedDescription)")
            throw AuthError.networkError
        }
    }

    func registerClient(username: String, email: String, password: String) async throws -> UserProfile {
        let url = baseURL.appendingPathComponent("api/auth/register/client")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["username": username, "email": email, "password": password]
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AuthError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                
                currentToken = authResponse.token
                currentUser = authResponse.user
                
                print("Успешная регистрация клиента: \(authResponse.user.username)")
                return authResponse.user
                
            case 400:
                if let errorData = try? JSONDecoder().decode([String: String].self, from: data),
                   let message = errorData["message"] {
                    if message.contains("уже существует") {
                        throw AuthError.userAlreadyExists
                    }
                    throw NSError(domain: "AuthError", code: 400,
                                userInfo: [NSLocalizedDescriptionKey: message])
                }
                throw AuthError.userAlreadyExists
                
            default:
                throw AuthError.networkError
            }
            
        } catch let error as AuthError {
            throw error
        } catch {
            print("Ошибка регистрации клиента: \(error.localizedDescription)")
            throw AuthError.networkError
        }
    }
    
    func registerMaster(username: String, email: String, password: String,
                       salonName: String, address: String) async throws -> UserProfile {
        let url = baseURL.appendingPathComponent("api/auth/register/master")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = [
            "username": username,
            "email": email,
            "password": password,
            "salonName": salonName,
            "address": address
        ]
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AuthError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                
                currentToken = authResponse.token
                currentUser = authResponse.user
                
                print("Успешная регистрация мастера: \(authResponse.user.username)")
                return authResponse.user
                
            case 400:
                if let errorData = try? JSONDecoder().decode([String: String].self, from: data),
                   let message = errorData["message"] {
                    if message.contains("уже существует") {
                        throw AuthError.userAlreadyExists
                    }
                    throw NSError(domain: "AuthError", code: 400,
                                userInfo: [NSLocalizedDescriptionKey: message])
                }
                throw AuthError.userAlreadyExists
                
            default:
                throw AuthError.networkError
            }
            
        } catch let error as AuthError {
            throw error
        } catch {
            print("Ошибка регистрации мастера: \(error.localizedDescription)")
            throw AuthError.networkError
        }
    }
    
    func refreshToken() async throws -> UserProfile {
        guard let token = currentToken else {
            throw AuthError.noToken
        }
        
        let url = baseURL.appendingPathComponent("api/auth/refresh")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AuthError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                
                currentToken = authResponse.token
                currentUser = authResponse.user
                
                print("Токен успешно обновлен")
                return authResponse.user
                
            case 401:
                logout()
                throw AuthError.noToken
                
            default:
                throw AuthError.networkError
            }
            
        } catch let error as AuthError {
            throw error
        } catch {
            print("Ошибка обновления токена: \(error.localizedDescription)")
            throw AuthError.networkError
        }
    }
    
    func getProfile() async throws -> UserProfile {
        guard let token = currentToken else {
            throw AuthError.noToken
        }
        
        let url = baseURL.appendingPathComponent("api/auth/profile")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AuthError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                let user = try JSONDecoder().decode(UserProfile.self, from: data)
                currentUser = user
                return user
                
            case 401:
                return try await refreshToken()
                
            default:
                throw AuthError.networkError
            }
            
        } catch let error as AuthError {
            throw error
        } catch {
            print("Ошибка получения профиля: \(error.localizedDescription)")
            throw AuthError.networkError
        }
    }
        
    func createAuthenticatedRequest(url: URL, method: String = "GET") throws -> URLRequest {
        guard let token = currentToken else {
            throw AuthError.noToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return request
    }
    
    
    private func isTokenExpired() -> Bool {
        guard let token = currentToken else { return true }
        
        return false
    }
}
