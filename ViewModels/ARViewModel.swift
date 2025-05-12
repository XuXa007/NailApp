import Foundation
import SwiftUI
import UIKit
import Combine

@MainActor
class ARViewModel: ObservableObject {
    @Published var maskImage: UIImage?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let processor = ARImageProcessor()
    private var cancellables = Set<AnyCancellable>()

    // Запросить маску для переданного UIImage
    func generateMask(from uiImage: UIImage, threshold: Double = 0.7) {
        maskImage = nil
        errorMessage = nil
        isLoading = true

        processor.fetchMask(for: uiImage, threshold: threshold)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case let .failure(err) = completion {
                    self?.errorMessage = "Ошибка: \(err.localizedDescription)"
                }
            } receiveValue: { [weak self] img in
                self?.maskImage = img
            }
            .store(in: &cancellables)
    }
}
