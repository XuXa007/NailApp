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
                self?.resultImage = resultImage
                self?.errorMessage = nil
            }
            .store(in: &cancellables)
    }
}
