import UIKit

extension UIImage {
    static func gradientImage(colors: [UIColor], size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let cgContext = context.cgContext
            let rect = CGRect(origin: .zero, size: size)
            
            // Создаем градиент
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let colorLocations: [CGFloat] = [0.0, 1.0]
            let cgColors = colors.map { $0.cgColor } as CFArray
            
            if let gradient = CGGradient(colorsSpace: colorSpace, colors: cgColors, locations: colorLocations) {
                
                // Рисуем линейный градиент
                let startPoint = CGPoint(x: 0, y: 0)
                let endPoint = CGPoint(x: size.width, y: 0)
                cgContext.drawLinearGradient(gradient,
                                           start: startPoint,
                                           end: endPoint,
                                           options: [])
            }
        }
        return image
    }
}
