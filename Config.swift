import Foundation

struct Config {
    static var baseURL: String {
        #if DEBUG
        return UserDefaults.standard.string(forKey: "server_url") ?? "http://localhost:8080"
        #else
        return "https://api.yournaildomain.com"
        #endif
    }
    
    static func setServerURL(_ url: String) {
        UserDefaults.standard.set(url, forKey: "server_url")
    }
}

