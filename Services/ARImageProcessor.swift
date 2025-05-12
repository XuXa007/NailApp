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
    
    func fetchMask(for image: UIImage, threshold: Double = 0.7) -> AnyPublisher<UIImage, Error> {
        guard let url = URL(string: "http://localhost:8000/mask?threshold=\(threshold)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        let data = image.pngData()!
        req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        req.httpBody = createBody(fieldName: "file", fileData: data, filename: "img.png")
        
        return URLSession.shared.dataTaskPublisher(for: req)
            .tryMap { data, resp in
                guard let img = UIImage(data: data) else {
                    throw URLError(.cannotDecodeContentData)
                }
                return img
            }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    private func createBody(fieldName: String,
                            fileData: Data,
                            filename: String) -> Data {
        var body = Data()
        let lineBreak = "\r\n"
        body.append("--\(boundary)\(lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(filename)\"\(lineBreak)")
        body.append("Content-Type: image/png\(lineBreak)\(lineBreak)")
        body.append(fileData)
        body.append(lineBreak)
        body.append("--\(boundary)--\(lineBreak)")
        return body
    }
}
