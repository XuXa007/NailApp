import Foundation

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
    
    // Добавьте эту структуру
    struct TryOn {
        static let defaultThreshold: Double = 0.7  // Порог для обнаружения ногтей
        static let defaultOpacity: Double = 0.9    // Прозрачность наложения дизайна
        static let maxImageDimension: CGFloat = 1200 // Максимальный размер изображения
    }
}
