import Foundation
import UIKit
import Combine


class ARImageProcessor {
    var cancellables = Set<AnyCancellable>()
    private let boundary = UUID().uuidString
    
    func tryOnDesign(base: UIImage, design: NailDesign, threshold: Double = 0.7, opacity: Double = 0.9) -> AnyPublisher<UIImage, Error> {
        guard let baseUrl = URL(string: Config.baseURL) else {
            print("Ошибка: не удалось создать URL из Config.baseURL: \(Config.baseURL)")
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
        
        let resizedImage = resizeImageIfNeeded(base, maxDimension: Config.TryOn.maxImageDimension)
        guard let baseData = resizedImage.jpegData(compressionQuality: 0.85) else {
            print("Ошибка: не удалось преобразовать изображение руки в JPEG")
            return Fail(error: URLError(.cannotDecodeRawData)).eraseToAnyPublisher()
        }
        
        print("Размер отправляемого изображения: \(baseData.count) байт")
        
        let designId = design.id
        print("ID дизайна: \(designId)")
        
        req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        req.httpBody = createMultipartBody(
            parts: [
                ("photo", baseData, "hand.jpg"),
                ("designId", designId.data(using: .utf8) ?? Data(), "")
            ]
        )
        
        req.timeoutInterval = 60.0
        
        print("Отправка запроса на сервер...")
        
        return URLSession.shared.dataTaskPublisher(for: req)
            .tryMap { data, resp in
                guard let httpResp = resp as? HTTPURLResponse else {
                    print("Ошибка: ответ не является HTTP-ответом")
                    throw URLError(.badServerResponse)
                }
                
                print("Получен ответ от сервера с кодом: \(httpResp.statusCode)")
                print("Размер ответа: \(data.count) байт")
                
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
    
    private func resizeImageIfNeeded(_ image: UIImage, maxDimension: CGFloat = 1200) -> UIImage {
        let size = image.size
        
        if size.width <= maxDimension && size.height <= maxDimension {
            return image
        }
        
        var newWidth: CGFloat
        var newHeight: CGFloat
        
        if size.width > size.height {
            newWidth = maxDimension
            newHeight = size.height * maxDimension / size.width
        } else {
            newHeight = maxDimension
            newWidth = size.width * maxDimension / size.height
        }
        
        let targetSize = CGSize(width: newWidth, height: newHeight)
        
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: targetSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        print("Изображение изменено с \(size.width)x\(size.height) на \(newWidth)x\(newHeight)")
        
        return resizedImage ?? image
    }
    
    private func createMultipartBody(parts: [(name: String, data: Data, filename: String)]) -> Data {
        var body = Data()
        let lineBreak = "\r\n"
        
        for part in parts {
            body.append("--\(boundary)\(lineBreak)")
            
            var partData = part.data
            if part.filename.hasSuffix(".jpg") || part.filename.hasSuffix(".jpeg") {
                if partData.count > 1_000_000 {
                    if let image = UIImage(data: partData),
                       let compressedData = image.jpegData(compressionQuality: 0.7) {
                        partData = compressedData
                        print("Изображение сжато с \(part.data.count) до \(partData.count) байт")
                    }
                }
            }
            
            if !part.filename.isEmpty {
                body.append("Content-Disposition: form-data; name=\"\(part.name)\"; filename=\"\(part.filename)\"\(lineBreak)")
                body.append("Content-Type: image/jpeg\(lineBreak)\(lineBreak)")
            } else {
                body.append("Content-Disposition: form-data; name=\"\(part.name)\"\(lineBreak)\(lineBreak)")
            }
            
            body.append(partData)
            body.append(lineBreak)
        }
        
        body.append("--\(boundary)--\(lineBreak)")
        return body
    }
}
