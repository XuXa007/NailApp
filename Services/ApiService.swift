import Foundation

enum ApiError: Error {
    case urlError
    case networkError(Error)
    case badResponse
    case decodingError(Error)
}

class ApiService {
    static let shared = ApiService()
    private init() {}
    
    private var baseURL: URL {
        guard let string = Bundle.main
            .object(forInfoDictionaryKey: "ServerURL") as? String,
              let url = URL(string: string)
        else {
            fatalError("ServerURL не задан")
        }
        return url
    }
    
    
    func fetchDesigns(using filter: DesignFilter) async throws -> [NailDesign] {
        var comps = URLComponents(url: baseURL.appendingPathComponent("api/designs"),
                                  resolvingAgainstBaseURL: false)
        let queryItems: [URLQueryItem] = []
        comps?.queryItems = queryItems.isEmpty ? nil : queryItems
        
        guard let url = comps?.url else {
            throw ApiError.urlError
        }
        print("[ApiService] GET \(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse {
                print("[ApiService] statusCode = \(http.statusCode)")
                if !(200..<300).contains(http.statusCode) {
                    let body = String(data: data, encoding: .utf8) ?? "<empty body>"
                    print("[ApiService] response body:\n\(body)")
                    throw ApiError.badResponse
                }
            }
            // парсим
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([NailDesign].self, from: data)
        } catch let err as ApiError {
            throw err
        } catch {
            throw ApiError.networkError(error)
        }
    }
    
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
    
    func fetchFavorites() async throws -> [NailDesign] {
        let url = baseURL.appendingPathComponent("/api/auth/favorites")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw ApiError.badResponse
        }
        return try JSONDecoder().decode([NailDesign].self, from: data)
    }
    
    
    func addFavorite(id: String) async throws {
        let url = baseURL.appendingPathComponent("/api/auth/favorites/\(id)")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw ApiError.badResponse
        }
    }
    
    func removeFavorite(id: String) async throws {
        let url = baseURL.appendingPathComponent("/api/auth/favorites/\(id)")
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw ApiError.badResponse
        }
    }
    

    func fetchDesigns(using filter: DesignFilter? = nil) async throws -> [NailDesign] {
        if filter == nil ||
           (filter!.selectedColors.isEmpty &&
            filter!.selectedStyles.isEmpty &&
            filter!.selectedSeasons.isEmpty &&
            filter!.selectedTypes.isEmpty) {
            
            let comps = URLComponents(url: baseURL.appendingPathComponent("api/designs"),
                                    resolvingAgainstBaseURL: false)
            guard let url = comps?.url else {
                throw ApiError.urlError
            }
            print("[ApiService] GET \(url.absoluteString)")
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            let (data, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse {
                print("[ApiService] statusCode = \(http.statusCode)")
                if !(200..<300).contains(http.statusCode) {
                    let body = String(data: data, encoding: .utf8) ?? "<empty body>"
                    print("[ApiService] response body:\n\(body)")
                    throw ApiError.badResponse
                }
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([NailDesign].self, from: data)
        } else {
            return try await fetchDesignsWithFilter(filter!)
        }
    }

    private func fetchDesignsWithFilter(_ filter: DesignFilter) async throws -> [NailDesign] {
        let url = baseURL.appendingPathComponent("api/designs/filter")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let filterData = [
            "colors": Array(filter.selectedColors.map { $0.rawValue }),
            "styles": Array(filter.selectedStyles.map { $0.rawValue }),
            "seasons": Array(filter.selectedSeasons.map { $0.rawValue }),
            "types": Array(filter.selectedTypes.map { $0.rawValue })
        ]
        
        request.httpBody = try JSONEncoder().encode(filterData)
        
        print("[ApiService] POST \(url.absoluteString)")
        print("[ApiService] Body: \(String(data: request.httpBody!, encoding: .utf8) ?? "")")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        if let http = response as? HTTPURLResponse {
            print("[ApiService] statusCode = \(http.statusCode)")
            if !(200..<300).contains(http.statusCode) {
                let body = String(data: data, encoding: .utf8) ?? "<empty body>"
                print("[ApiService] response body:\n\(body)")
                throw ApiError.badResponse
            }
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([NailDesign].self, from: data)
    }
    
}
