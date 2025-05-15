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
    
    func tryOnDesign(handImage: UIImage, design: NailDesign) {
        isLoading = true
        errorMessage = nil
        resultImage = nil
        
        processor.tryOnDesign(base: handImage, design: design)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.errorMessage = "Ошибка обработки: \(error.localizedDescription)"
                }
            } receiveValue: { [weak self] resultImage in
                // Здесь можно добавить сжатие изображения если нужно
                let compressedImage = self?.compressImage(resultImage, maxSize: 1024) ?? resultImage
                self?.resultImage = compressedImage
                self?.errorMessage = nil
            }
            .store(in: &cancellables)
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
        
        return resizedImage ?? image
    }
}
