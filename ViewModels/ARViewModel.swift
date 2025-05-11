import Foundation
import SwiftUI
import UIKit

@MainActor
class ARViewModel: ObservableObject {
    @Published var selectedImage: UIImage? = nil
    @Published var outputImage: UIImage? = nil
    
    func apply(design: UIImage) {
        guard let input = selectedImage else { return }
        outputImage = ARImageProcessor.apply(design: design, to: input)
    }
}
