import Foundation

enum ApiError: Error, LocalizedError {
    case urlError
    case networkError(Error)
    case badResponse
    case decodingError(Error)
    case unauthorized
    case forbidden
    case notFound
    case serverError(String)
    case invalidData
    case timeout
    
    var errorDescription: String? {
        switch self {
        case .urlError:
            return "Некорректный URL запроса"
        case .networkError(let error):
            return "Ошибка сети: \(error.localizedDescription)"
        case .badResponse:
            return "Некорректный ответ сервера"
        case .decodingError(let error):
            return "Ошибка декодирования данных: \(error.localizedDescription)"
        case .unauthorized:
            return "Ошибка авторизации"
        case .forbidden:
            return "Доступ запрещен"
        case .notFound:
            return "Ресурс не найден"
        case .serverError(let message):
            return "Ошибка сервера: \(message)"
        case .invalidData:
            return "Некорректные данные"
        case .timeout:
            return "Превышено время ожидания"
        }
    }
    
    var isAuthenticationError: Bool {
        switch self {
        case .unauthorized, .forbidden:
            return true
        default:
            return false
        }
    }
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
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                if let http = response as? HTTPURLResponse {
                    if !(200..<300).contains(http.statusCode) {
                        throw ApiError.badResponse
                    }
                }
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return try decoder.decode([NailDesign].self, from: data)
            } catch {
                if error is ApiError {
                    throw error
                } else {
                    throw ApiError.networkError(error)
                }
            }
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
        
        do {
            request.httpBody = try JSONEncoder().encode(filterData)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse {
                if !(200..<300).contains(http.statusCode) {
                    throw ApiError.badResponse
                }
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([NailDesign].self, from: data)
        } catch {
            if error is ApiError {
                throw error
            } else {
                throw ApiError.networkError(error)
            }
        }
    }
    
    
    func fetchFavorites() async throws -> [NailDesign] {
        let url = baseURL.appendingPathComponent("api/auth/favorites")
        let request = try AuthService.shared.createAuthenticatedRequest(url: url)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                throw ApiError.badResponse
            }
            
            if http.statusCode == 401 {
                try await AuthService.shared.refreshToken()
                return try await fetchFavorites() // Повторяем запрос
            }
            
            if !(200..<300).contains(http.statusCode) {
                switch http.statusCode {
                case 403:
                    throw ApiError.forbidden
                case 404:
                    throw ApiError.notFound
                default:
                    throw ApiError.badResponse
                }
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([NailDesign].self, from: data)
        } catch {
            if error is ApiError || error is AuthError {
                throw error
            } else {
                throw ApiError.networkError(error)
            }
        }
    }
    
    func addFavorite(id: String) async throws {
        let url = baseURL.appendingPathComponent("api/auth/favorites/\(id)")
        let request = try AuthService.shared.createAuthenticatedRequest(url: url, method: "POST")
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                throw ApiError.badResponse
            }
            
            if http.statusCode == 401 {
                try await AuthService.shared.refreshToken()
                return try await addFavorite(id: id)
            }
            
            if !(200..<300).contains(http.statusCode) {
                switch http.statusCode {
                case 403:
                    throw ApiError.forbidden
                case 404:
                    throw ApiError.notFound
                default:
                    throw ApiError.badResponse
                }
            }
        } catch {
            if error is ApiError || error is AuthError {
                throw error
            } else {
                throw ApiError.networkError(error)
            }
        }
    }
    
    func removeFavorite(id: String) async throws {
        let url = baseURL.appendingPathComponent("api/auth/favorites/\(id)")
        let request = try AuthService.shared.createAuthenticatedRequest(url: url, method: "DELETE")
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                throw ApiError.badResponse
            }
            
            if http.statusCode == 401 {
                try await AuthService.shared.refreshToken()
                return try await removeFavorite(id: id)
            }
            
            if !(200..<300).contains(http.statusCode) {
                switch http.statusCode {
                case 403:
                    throw ApiError.forbidden
                case 404:
                    throw ApiError.notFound
                default:
                    throw ApiError.badResponse
                }
            }
        } catch {
            if error is ApiError || error is AuthError {
                throw error
            } else {
                throw ApiError.networkError(error)
            }
        }
    }
    
    
    func getMasterDesigns() async throws -> [NailDesign] {
        let url = baseURL.appendingPathComponent("api/master/designs/my")
        let request = try AuthService.shared.createAuthenticatedRequest(url: url)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                throw ApiError.badResponse
            }
            
            if http.statusCode == 401 {
                try await AuthService.shared.refreshToken()
                return try await getMasterDesigns()
            }
            
            if !(200..<300).contains(http.statusCode) {
                switch http.statusCode {
                case 403:
                    throw ApiError.forbidden
                case 404:
                    throw ApiError.notFound
                default:
                    throw ApiError.badResponse
                }
            }
            
            return try JSONDecoder().decode([NailDesign].self, from: data)
        } catch {
            if error is ApiError || error is AuthError {
                throw error
            } else {
                throw ApiError.networkError(error)
            }
        }
    }
    
    func uploadDesign(name: String, description: String,
                     designType: String, color: String,
                     occasion: String, length: String,
                     material: String, image: Data) async throws -> NailDesign {
        
        let url = baseURL.appendingPathComponent("api/master/designs")
        
        guard let token = AuthService.shared.currentToken else {
            throw AuthError.noToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
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
            "material": material
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
        
        do {
            let (data, resp) = try await URLSession.shared.data(for: request)
            guard let http = resp as? HTTPURLResponse else {
                throw ApiError.badResponse
            }
            
            if http.statusCode == 401 {
                try await AuthService.shared.refreshToken()
                return try await uploadDesign(name: name, description: description, designType: designType, color: color, occasion: occasion, length: length, material: material, image: image)
            }
            
            if !(200..<300).contains(http.statusCode) {
                switch http.statusCode {
                case 403:
                    throw ApiError.forbidden
                case 404:
                    throw ApiError.notFound
                default:
                    throw ApiError.badResponse
                }
            }
            
            return try JSONDecoder().decode(NailDesign.self, from: data)
        } catch {
            if error is ApiError || error is AuthError {
                throw error
            } else {
                throw ApiError.networkError(error)
            }
        }
    }
    
    func updateDesign(design: NailDesign) async throws -> NailDesign {
        let url = baseURL.appendingPathComponent("api/master/designs/\(design.id)")
        var request = try AuthService.shared.createAuthenticatedRequest(url: url, method: "PUT")
        
        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(design)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ApiError.badResponse
            }
            
            if httpResponse.statusCode == 401 {
                try await AuthService.shared.refreshToken()
                return try await updateDesign(design: design)
            }
            
            if !(200..<300).contains(httpResponse.statusCode) {
                switch httpResponse.statusCode {
                case 403:
                    throw ApiError.forbidden
                case 404:
                    throw ApiError.notFound
                default:
                    throw ApiError.badResponse
                }
            }
            
            let decoder = JSONDecoder()
            return try decoder.decode(NailDesign.self, from: data)
        } catch {
            if error is ApiError || error is AuthError {
                throw error
            } else {
                throw ApiError.networkError(error)
            }
        }
    }
    
    func deleteDesign(id: String) async throws {
        let url = baseURL.appendingPathComponent("api/master/designs/\(id)")
        let request = try AuthService.shared.createAuthenticatedRequest(url: url, method: "DELETE")
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ApiError.badResponse
            }
            
            if httpResponse.statusCode == 401 {
                try await AuthService.shared.refreshToken()
                return try await deleteDesign(id: id)
            }
            
            if !(200..<300).contains(httpResponse.statusCode) {
                switch httpResponse.statusCode {
                case 403:
                    throw ApiError.forbidden
                case 404:
                    throw ApiError.notFound
                default:
                    throw ApiError.badResponse
                }
            }
        } catch {
            if error is ApiError || error is AuthError {
                throw error
            } else {
                throw ApiError.networkError(error)
            }
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
