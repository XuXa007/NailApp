import Foundation

class AuthService {
    static let shared = AuthService()
    private init() {}
    private var baseURL: URL {
        guard let url = URL(string: Config.baseURL) else {
            fatalError("Base URL is not a valid URL")
        }
        return url
    }
    func login(username: String, password: String) async throws -> UserProfile {
        let url = baseURL.appendingPathComponent("api/auth/login")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["username": username, "password": password]
        req.httpBody = try JSONEncoder().encode(body)
        
        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, 200..<300 ~= http.statusCode
        else { throw ApiError.badResponse }
        
        return try JSONDecoder().decode(UserProfile.self, from: data)
    }

    func registerClient(username: String, email: String, password: String) async throws -> UserProfile {
        let url = baseURL.appendingPathComponent("api/auth/register/client")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["username": username, "email": email, "password": password]
        req.httpBody = try JSONEncoder().encode(body)
        
        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, 200..<300 ~= http.statusCode
        else { throw ApiError.badResponse }
        
        return try JSONDecoder().decode(UserProfile.self, from: data)
    }
    
    func registerMaster(username: String, email: String, password: String, salonName: String, address: String) async throws -> UserProfile {
            let url = baseURL.appendingPathComponent("api/auth/register/master")
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let body = [
                "username": username,
                "email": email,
                "password": password,
                "salonName": salonName,
                "address": address
            ]
            req.httpBody = try JSONEncoder().encode(body)
            
            let (data, resp) = try await URLSession.shared.data(for: req)
            guard let http = resp as? HTTPURLResponse, 200..<300 ~= http.statusCode
            else { throw ApiError.badResponse }
            
            return try JSONDecoder().decode(UserProfile.self, from: data)
        }
    }
