import Foundation
import UIKit

struct Config {
    static var baseURL: String {
        #if DEBUG
        return UserDefaults.standard.string(forKey: "server_url") ?? "http://192.168.1.8:8080"
        #else
        return "https://api.yournaildomain.com"
        #endif
    }
    
    static func setServerURL(_ url: String) {
        UserDefaults.standard.set(url, forKey: "server_url")
    }
    
    struct TryOn {
        static let defaultThreshold: Double = 0.7  // Порог для обнаружения ногтей
        static let defaultOpacity: Double = 0.9    // Прозрачность наложения дизайна
        static let maxImageDimension: CGFloat = 1200 // Максимальный размер изображения
        
        // Настройки детекции руки в кадре
        struct Detection {
            static let handDetectionInterval: TimeInterval = 0.3 // Интервал проверки наличия руки
            static let minHandConfidence: Double = 0.6 // Минимальная уверенность в детекции руки
            static let idealLightLevel: ClosedRange<Double> = 0.4...0.85 // Идеальный диапазон освещенности
            
            // Область интереса для размещения руки (относительные координаты от центра экрана)
            static let handRegionOfInterest = CGRect(x: -0.4, y: -0.35, width: 0.8, height: 0.7)
        }
        
        // Настройки обработки изображения
        struct Processing {
            static let jpegCompressionQuality: CGFloat = 0.85 // Качество JPEG
            static let maxUploadSize: Int = 5 * 1024 * 1024 // Максимальный размер загрузки (5МБ)
            static let preferredAspectRatio: CGFloat = 4.0 / 3.0 // Предпочтительное соотношение сторон
        }
    }
    
    // Настройки UI
    struct UI {
        static let primaryColor = UIColor(red: 0.5, green: 0.3, blue: 0.8, alpha: 1.0)
        static let secondaryColor = UIColor(red: 0.3, green: 0.6, blue: 0.9, alpha: 1.0)
        static let backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1.0)
        
        // Анимации
        static let standardAnimationDuration: TimeInterval = 0.3
        static let springAnimation = (damping: CGFloat(0.6), velocity: CGFloat(0.8))
    }
    
    // Таймауты запросов
    struct Network {
        static let standardTimeout: TimeInterval = 30.0
        static let uploadTimeout: TimeInterval = 60.0
        static let retryCount = 2
        static let retryDelay: TimeInterval = 2.0
    }
    
    // Настройки кэша
    struct Cache {
        static let maxDiskCacheSize: Int = 100 * 1024 * 1024 // 100MB
        static let maxMemoryCacheSize: Int = 30 * 1024 * 1024 // 30MB
        static let designThumbCacheDuration: TimeInterval = 7 * 24 * 60 * 60 // 7 дней
    }
    
}
