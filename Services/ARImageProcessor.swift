import UIKit

class ARImageProcessor {
    static func apply(design: UIImage, to image: UIImage) -> UIImage {
        // Stub: overlay design
        UIGraphicsBeginImageContext(image.size)
        image.draw(at: .zero)
        design.draw(in: CGRect(origin: .zero, size: image.size), blendMode: .normal, alpha: 0.5)
        let result = UIGraphicsGetImageFromCurrentImageContext() ?? image
        UIGraphicsEndImageContext()
        return result
    }
}
