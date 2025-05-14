import Foundation
import UIKit
import Combine

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

class ARImageProcessor {
    private let boundary = UUID().uuidString
    
    func tryOnDesign(base: UIImage, design: NailDesign, threshold: Double = 0.7, opacity: Double = 0.9) -> AnyPublisher<UIImage, Error> {
        guard let baseUrlString = Bundle.main.object(forInfoDictionaryKey: "ServerURL") as? String,
              let baseUrl = URL(string: baseUrlString) else {
            print("Ошибка: не удалось получить базовый URL из Info.plist")
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        print("Базовый URL: \(baseUrl)")
        
        let tryOnUrl = baseUrl.appendingPathComponent("api/tryon")
        
        var components = URLComponents(url: tryOnUrl, resolvingAgainstBaseURL: true)
        components?.queryItems = [
            URLQueryItem(name: "threshold", value: String(threshold)),
            URLQueryItem(name: "opacity", value: String(opacity))
        ]
        
        guard let finalUrl = components?.url else {
            print("Ошибка: не удалось построить URL с параметрами")
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        print("Полный URL запроса: \(finalUrl)")
        
        var req = URLRequest(url: finalUrl)
        req.httpMethod = "POST"
        
        guard let baseData = base.jpegData(compressionQuality: 0.8) else {
            print("Ошибка: не удалось преобразовать изображение руки в JPEG")
            return Fail(error: URLError(.cannotDecodeRawData)).eraseToAnyPublisher()
        }
        
        let designId = design.id
        print("ID дизайна: \(designId)")
        
        req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        req.httpBody = createMultipartBody(
            parts: [
                ("photo", baseData, "hand.jpg"),
                ("designId", designId.data(using: .utf8) ?? Data(), "")
            ]
        )
        
        print("Отправка запроса на сервер...")
        
        return URLSession.shared.dataTaskPublisher(for: req)
            .tryMap { data, resp in
                guard let httpResp = resp as? HTTPURLResponse else {
                    print("Ошибка: ответ не является HTTP-ответом")
                    throw URLError(.badServerResponse)
                }
                
                print("Получен ответ от сервера с кодом: \(httpResp.statusCode)")
                
                if !(200...299).contains(httpResp.statusCode) {
                    let respString = String(data: data, encoding: .utf8) ?? "Unknown error"
                    print("Ошибка сервера: \(respString)")
                    throw URLError(.badServerResponse)
                }
                
                guard let img = UIImage(data: data) else {
                    print("Ошибка: не удалось преобразовать данные в изображение")
                    throw URLError(.cannotDecodeContentData)
                }
                
                print("Изображение успешно получено")
                return img
            }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    private func createMultipartBody(parts: [(name: String, data: Data, filename: String)]) -> Data {
        var body = Data()
        let lineBreak = "\r\n"
        
        for part in parts {
            body.append("--\(boundary)\(lineBreak)")
            
            if !part.filename.isEmpty {
                body.append("Content-Disposition: form-data; name=\"\(part.name)\"; filename=\"\(part.filename)\"\(lineBreak)")
                body.append("Content-Type: image/jpeg\(lineBreak)\(lineBreak)")
            } else {
                body.append("Content-Disposition: form-data; name=\"\(part.name)\"\(lineBreak)\(lineBreak)")
            }
            
            body.append(part.data)
            body.append(lineBreak)
        }
        
        body.append("--\(boundary)--\(lineBreak)")
        return body
    }
}
