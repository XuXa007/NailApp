import Foundation
import SwiftUI
import UIKit
import Combine

@MainActor
class ARViewModel: ObservableObject {
    @Published var maskImage: UIImage?
    @Published var resultImage: UIImage?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let processor = ARImageProcessor()
    private var cancellables = Set<AnyCancellable>()
    
    func tryOnDesign(handImage: UIImage, design: NailDesign,
                     threshold: Double = Config.TryOn.defaultThreshold,
                     opacity: Double = Config.TryOn.defaultOpacity) {
        isLoading = true
        errorMessage = nil
        resultImage = nil
        
        processor.tryOnDesign(base: handImage, design: design, threshold: threshold, opacity: opacity)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.handleError(error)
                }
            } receiveValue: { [weak self] resultImage in
                // Сжимаем изображение если нужно
                let compressedImage = self?.compressImage(resultImage, maxSize: 1024) ?? resultImage
                self?.resultImage = compressedImage
                self?.errorMessage = nil
            }
            .store(in: &cancellables)
    }
    
    private func handleError(_ error: Error) {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .timedOut:
                errorMessage = "Превышен лимит ожидания. Проверьте соединение."
            case .notConnectedToInternet:
                errorMessage = "Отсутствует подключение к интернету."
            case .badServerResponse:
                if let nsError = error as NSError?, nsError.localizedDescription.contains("422") {
                    errorMessage = "422" // Код для "Не найдены ногти"
                } else {
                    errorMessage = "Ошибка сервера. Попробуйте позже."
                }
            default:
                errorMessage = "Ошибка обработки: \(urlError.localizedDescription)"
            }
        } else {
            errorMessage = "Ошибка: \(error.localizedDescription)"
        }
    }
    
    func compressImage(_ image: UIImage, maxSize: CGFloat) -> UIImage {
        let aspectRatio = image.size.width / image.size.height
        
        var newSize: CGSize
        if image.size.width > image.size.height {
            newSize = CGSize(width: maxSize, height: maxSize / aspectRatio)
        } else {
            newSize = CGSize(width: maxSize * aspectRatio, height: maxSize)
        }
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let compressedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        
        return compressedImage
    }
}
