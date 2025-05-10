// Services/ApiService.swift
import Foundation

/// Ошибки сетевого слоя
enum ApiError: Error {
    case urlError
    case networkError(Error)
    case badResponse
    case decodingError(Error)
}

/// Синглтон для всех HTTP-запросов
class ApiService {
    static let shared = ApiService()
    private init() {}
    
    private var baseURL: URL {
        guard let string = Bundle.main
            .object(forInfoDictionaryKey: "ServerURL") as? String,
              let url = URL(string: string)
        else {
            fatalError("ServerURL не задан в Info.plist")
        }
        return url
    }
    
    
    // MARK: — Получить все дизайны по фильтру
    func fetchDesigns(using filter: DesignFilter) async throws -> [NailDesign] {
        // Собираем URLComponents из baseURL + путь
        var comps = URLComponents(url: baseURL.appendingPathComponent("/api/designs"),
                                  resolvingAgainstBaseURL: false)
        var queryItems: [URLQueryItem] = []
        
        if !filter.selectedColors.isEmpty {
            let v = filter.selectedColors.map { $0.rawValue }.joined(separator: ",")
            queryItems.append(.init(name: "colors", value: v))
        }
        if !filter.selectedStyles.isEmpty {
            let v = filter.selectedStyles.map { $0.rawValue }.joined(separator: ",")
            queryItems.append(.init(name: "styles", value: v))
        }
        if !filter.selectedSeasons.isEmpty {
            let v = filter.selectedSeasons.map { $0.rawValue }.joined(separator: ",")
            queryItems.append(.init(name: "seasons", value: v))
        }
        if !filter.selectedTypes.isEmpty {
            let v = filter.selectedTypes.map { $0.rawValue }.joined(separator: ",")
            queryItems.append(.init(name: "types", value: v))
        }
        comps?.queryItems = queryItems.isEmpty ? nil : queryItems
        
        guard let url = comps?.url else {
            throw ApiError.urlError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let http = response as? HTTPURLResponse,
                  200..<300 ~= http.statusCode
            else {
                throw ApiError.badResponse
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return try decoder.decode([NailDesign].self, from: data)
            } catch {
                throw ApiError.decodingError(error)
            }
            
        } catch {
            throw ApiError.networkError(error)
        }
    }
    
    // MARK: — Пример логина
    func login(username: String, password: String) async throws -> UserProfile {
        let url = baseURL.appendingPathComponent("/api/auth/login")
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
    
    // MARK: — Пример регистрации
    func register(username: String, email: String, password: String) async throws -> UserProfile {
        let url = baseURL.appendingPathComponent("/api/auth/register")
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
}
