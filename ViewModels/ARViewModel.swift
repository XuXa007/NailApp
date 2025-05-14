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
    
    func tryOnDesign(handImage: UIImage, designURL: URL) {
        isLoading = true
        errorMessage = nil
        resultImage = nil
        
        URLSession.shared.dataTaskPublisher(for: designURL)
            .map { UIImage(data: $0.data) }
            .compactMap { $0 }
            .mapError { $0 as Error }
            .flatMap { [weak self] designImage -> AnyPublisher<UIImage, Error> in
                guard let self = self else {
                    return Fail(error: URLError(.cancelled)).eraseToAnyPublisher()
                }
                return self.processor.tryOnDesign(base: handImage, design: designImage)
            }
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.errorMessage = "Ошибка: \(error.localizedDescription)"
                }
            } receiveValue: { [weak self] resultImage in
                self?.resultImage = resultImage
            }
            .store(in: &cancellables)
    }
    
    func generateMask(from handImage: UIImage) {
        isLoading = true
        errorMessage = nil
        maskImage = nil
        
        processor.fetchMask(for: handImage)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.errorMessage = "Ошибка создания маски: \(error.localizedDescription)"
                }
            } receiveValue: { [weak self] mask in
                self?.maskImage = mask
            }
            .store(in: &cancellables)
    }
}
