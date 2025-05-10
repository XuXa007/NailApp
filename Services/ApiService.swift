import Foundation
import UIKit

class ApiService {
    static let shared = ApiService()
    
    // В тестовом режиме можно использовать localhost
    // Для реального устройства нужно использовать IP-адрес компьютера
    let baseURL = "http://localhost:8080/api"
    
    // MARK: - Дизайны
    
    // Получение дизайнов по фильтрам
    func getDesigns(filters: DesignFilters, completion: @escaping ([NailDesign]?, Error?) -> Void) {
        // В демо-режиме возвращаем тестовые данные
        #if DEBUG
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(NailDesign.demoDesigns(), nil)
        }
        return
        #endif
        
        // Параметры запроса
        let params = filters.toQueryParameters()
        var urlComponents = URLComponents(string: "\(baseURL)/designs")!
        urlComponents.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        // Выполнение запроса
        guard let url = urlComponents.url else {
            completion(nil, NSError(domain: "Invalid URL", code: -1, userInfo: nil))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "No data", code: -2, userInfo: nil))
                return
            }
            
            do {
                let designs = try JSONDecoder().decode([NailDesign].self, from: data)
                completion(designs, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
    
    // Получение популярных дизайнов
    func getPopularDesigns(completion: @escaping ([NailDesign]?, Error?) -> Void) {
        // В демо-режиме возвращаем тестовые данные
        #if DEBUG
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(NailDesign.demoDesigns(), nil)
        }
        return
        #endif
        
        let url = URL(string: "\(baseURL)/designs/popular")!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "No data", code: -2, userInfo: nil))
                return
            }
            
            do {
                let designs = try JSONDecoder().decode([NailDesign].self, from: data)
                completion(designs, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
    
    // MARK: - Аутентификация
    
    // Вход в систему
    func login(email: String, password: String, completion: @escaping (UserProfile?, Error?) -> Void) {
        // В демо-режиме создаем фиктивного пользователя
        #if DEBUG
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let profile = UserProfile(
                id: 1,
                username: "Пользователь",
                email: email,
                isGuest: false,
                favoriteDesigns: []
            )
            UserProfile.current = profile
            completion(profile, nil)
        }
        return
        #endif
        
        let url = URL(string: "\(baseURL)/auth/login")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "No data", code: -2, userInfo: nil))
                return
            }
            
            do {
                let profile = try JSONDecoder().decode(UserProfile.self, from: data)
                UserProfile.current = profile
                completion(profile, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
    
    // Регистрация
    func register(username: String, email: String, password: String, completion: @escaping (UserProfile?, Error?) -> Void) {
        // В демо-режиме создаем фиктивного пользователя
        #if DEBUG
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let profile = UserProfile(
                id: 1,
                username: username,
                email: email,
                isGuest: false,
                favoriteDesigns: []
            )
            UserProfile.current = profile
            completion(profile, nil)
        }
        return
        #endif
        
        let url = URL(string: "\(baseURL)/auth/register")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "username": username,
            "email": email,
            "password": password
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "No data", code: -2, userInfo: nil))
                return
            }
            
            do {
                let profile = try JSONDecoder().decode(UserProfile.self, from: data)
                UserProfile.current = profile
                completion(profile, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
    
    // Вход как гость
    func loginAsGuest(completion: @escaping (UserProfile?, Error?) -> Void) {
        let guestProfile = UserProfile.createGuestProfile()
        UserProfile.current = guestProfile
        completion(guestProfile, nil)
    }
    
    // MARK: - Избранное
    
    // Добавление в избранное
    func addToFavorites(designId: Int, completion: @escaping (Bool, Error?) -> Void) {
        // В демо-режиме обновляем локальный профиль
        #if DEBUG
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UserProfile.current?.addToFavorites(designId: designId)
            completion(true, nil)
        }
        return
        #endif
        
        guard let userId = UserProfile.current?.id, !UserProfile.current!.isGuest else {
            completion(false, NSError(domain: "Not logged in", code: -1, userInfo: nil))
            return
        }
        
        let url = URL(string: "\(baseURL)/favorites/add")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "userId": userId,
            "designId": designId
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(false, error)
                return
            }
            
            UserProfile.current?.addToFavorites(designId: designId)
            completion(true, nil)
        }.resume()
    }
    
    // Удаление из избранного
    func removeFromFavorites(designId: Int, completion: @escaping (Bool, Error?) -> Void) {
        // В демо-режиме обновляем локальный профиль
        #if DEBUG
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UserProfile.current?.removeFromFavorites(designId: designId)
            completion(true, nil)
        }
        return
        #endif
        
        guard let userId = UserProfile.current?.id, !UserProfile.current!.isGuest else {
            completion(false, NSError(domain: "Not logged in", code: -1, userInfo: nil))
            return
        }
        
        let url = URL(string: "\(baseURL)/favorites/remove")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "userId": userId,
            "designId": designId
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(false, error)
                return
            }
            
            UserProfile.current?.removeFromFavorites(designId: designId)
            completion(true, nil)
        }.resume()
    }
    
    // MARK: - AR и обработка изображений
    
    // Применение дизайна к фотографии
    func applyDesignToPhoto(photo: UIImage, designId: Int, completion: @escaping (UIImage?, Error?) -> Void) {
        // Создаем multipart запрос для отправки изображения
        let url = URL(string: "\(baseURL)/ar/apply-design")!
        
        // Создаем граничный строку для multipart/form-data
        let boundary = "Boundary-\(UUID().uuidString)"
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Создаем body запроса
        var httpBody = Data()
        
        // Добавляем designId
        httpBody.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        httpBody.append("Content-Disposition: form-data; name=\"designId\"\r\n\r\n".data(using: .utf8)!)
        httpBody.append("\(designId)".data(using: .utf8)!)
        
        // Добавляем изображение
        httpBody.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        httpBody.append("Content-Disposition: form-data; name=\"photo\"; filename=\"photo.jpg\"\r\n".data(using: .utf8)!)
        httpBody.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        
        if let imageData = photo.jpegData(compressionQuality: 0.8) {
            httpBody.append(imageData)
        }
        
        // Завершаем body
        httpBody.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = httpBody
        
        // В демо-режиме имитируем обработку изображения
        #if DEBUG
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // Создаем простую имитацию наложения дизайна
            UIGraphicsBeginImageContextWithOptions(photo.size, false, photo.scale)
            
            // Рисуем исходное фото
            photo.draw(in: CGRect(origin: .zero, size: photo.size))
            
            // Рисуем простой overlay для имитации эффекта
            let overlayColor = UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 0.3)
            overlayColor.setFill()
            
            // Рисуем несколько случайных кругов, имитирующих ногти с дизайном
            for _ in 0..<5 {
                let x = CGFloat.random(in: 0..<photo.size.width)
                let y = CGFloat.random(in: 0..<photo.size.height)
                let size = CGFloat.random(in: 30..<50)
                
                let rect = CGRect(x: x, y: y, width: size, height: size)
                UIBezierPath(ovalIn: rect).fill()
            }
            
            let resultImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            completion(resultImage, nil)
        }
        return
        #endif
        
        // Выполняем запрос
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "No data", code: -2, userInfo: nil))
                return
            }
            
            if let image = UIImage(data: data) {
                completion(image, nil)
            } else {
                completion(nil, NSError(domain: "Invalid image data", code: -3, userInfo: nil))
            }
        }.resume()
    }
}
