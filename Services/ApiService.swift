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
        let url = baseURL.appendingPathComponent("api/auth/favorites")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw ApiError.badResponse
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([NailDesign].self, from: data)
    }
    
    func addFavorite(id: String) async throws {
        let url = baseURL.appendingPathComponent("api/auth/favorites/\(id)")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw ApiError.badResponse
        }
    }
    
    func removeFavorite(id: String) async throws {
        let url = baseURL.appendingPathComponent("api/auth/favorites/\(id)")
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
    
    func registerMaster(username: String, email: String, password: String,
                        salonName: String, address: String) async throws -> UserProfile {
        let url = baseURL.appendingPathComponent("/api/auth/register/master")
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
    
    func getMasterDesigns(username: String) async throws -> [NailDesign] {
        let url = baseURL.appendingPathComponent("/api/master/designs/my")
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        components?.queryItems = [URLQueryItem(name: "username", value: username)]
        
        guard let requestURL = components?.url else {
            throw ApiError.urlError
        }
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "GET"
        
        let (data, resp) = try await URLSession.shared.data(for: request)
        guard let http = resp as? HTTPURLResponse, 200..<300 ~= http.statusCode
        else { throw ApiError.badResponse }
        
        return try JSONDecoder().decode([NailDesign].self, from: data)
    }
    
    func uploadDesign(name: String, description: String,
                     designType: String, color: String,
                     occasion: String, length: String,
                     material: String, image: Data,
                     username: String) async throws -> NailDesign {
        let url = baseURL.appendingPathComponent("/api/master/designs")
        
        // Создаем multipart/form-data запрос
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Добавляем текстовые поля
        let fields = [
            "name": name,
            "description": description,
            "designType": designType,
            "color": color,
            "occasion": occasion,
            "length": length,
            "material": material,
            "username": username
        ]
        
        for (key, value) in fields {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.append("\(value)\r\n")
        }
        
        // Добавляем изображение
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"design.jpg\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(image)
        body.append("\r\n")
        
        body.append("--\(boundary)--\r\n")
        
        request.httpBody = body
        
        let (data, resp) = try await URLSession.shared.data(for: request)
        guard let http = resp as? HTTPURLResponse, 200..<300 ~= http.statusCode
        else { throw ApiError.badResponse }
        
        return try JSONDecoder().decode(NailDesign.self, from: data)
    }
        
    func updateDesign(design: NailDesign, username: String) async throws -> NailDesign {
        guard let url = URL(string: "\(baseURL)/api/master/designs/\(design.id)") else {
            throw ApiError.urlError
        }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        components?.queryItems = [URLQueryItem(name: "username", value: username)]
        
        guard let requestURL = components?.url else {
            throw ApiError.urlError
        }
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Кодируем дизайн в JSON
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(design)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw ApiError.badResponse
        }
        
        // Декодируем и возвращаем обновленный дизайн
        let decoder = JSONDecoder()
        return try decoder.decode(NailDesign.self, from: data)
    }
    
    func deleteDesign(id: String, username: String) async throws {
         guard let url = URL(string: "\(baseURL)/api/master/designs/\(id)") else {
             throw ApiError.urlError
         }
         
         var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
         components?.queryItems = [URLQueryItem(name: "username", value: username)]
         
         guard let requestURL = components?.url else {
             throw ApiError.urlError
         }
         
         var request = URLRequest(url: requestURL)
         request.httpMethod = "DELETE"
         
         let (_, response) = try await URLSession.shared.data(for: request)
         
         guard let httpResponse = response as? HTTPURLResponse,
               200..<300 ~= httpResponse.statusCode else {
             throw ApiError.badResponse
         }
     }
    
    func fetchFavorites(username: String = "demo_client") async throws -> [NailDesign] {
        var components = URLComponents(url: baseURL.appendingPathComponent("api/auth/favorites"), resolvingAgainstBaseURL: true)
        components?.queryItems = [URLQueryItem(name: "username", value: username)]
        
        guard let url = components?.url else {
            throw ApiError.urlError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        print("[ApiService] GET \(url.absoluteString)")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw ApiError.badResponse
        }
        
        print("[ApiService] Favorites response status: \(http.statusCode)")
        
        if !(200..<300).contains(http.statusCode) {
            let body = String(data: data, encoding: .utf8) ?? "<empty body>"
            print("[ApiService] Favorites error response: \(body)")
            throw ApiError.badResponse
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([NailDesign].self, from: data)
    }

    func addFavorite(id: String, username: String = "demo_client") async throws {
        var components = URLComponents(url: baseURL.appendingPathComponent("api/auth/favorites/\(id)"), resolvingAgainstBaseURL: true)
        components?.queryItems = [URLQueryItem(name: "username", value: username)]
        
        guard let url = components?.url else {
            throw ApiError.urlError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        print("[ApiService] POST \(url.absoluteString)")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw ApiError.badResponse
        }
    }

    func removeFavorite(id: String, username: String = "demo_client") async throws {
        var components = URLComponents(url: baseURL.appendingPathComponent("api/auth/favorites/\(id)"), resolvingAgainstBaseURL: true)
        components?.queryItems = [URLQueryItem(name: "username", value: username)]
        
        guard let url = components?.url else {
            throw ApiError.urlError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        print("[ApiService] DELETE \(url.absoluteString)")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw ApiError.badResponse
        }
    }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}
