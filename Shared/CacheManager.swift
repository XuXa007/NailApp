import Foundation
import UIKit

class CacheManager {
    static let shared = CacheManager()
    private init() {}
    
    func clearImageCache() {
        URLCache.shared.removeAllCachedResponses()
        let cache = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
        URLCache.shared = cache
        URLSession.shared.configuration.urlCache = cache
        
        print("✅ Image cache cleared")
    }
    
    func clearAppCaches() {
        clearImageCache()
        let serverURL = Config.baseURL
        
        let dictionary = UserDefaults.standard.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            if key != "server_url" {
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
        
        Config.setServerURL(serverURL)
        
        print("✅ App caches cleared")
    }
}
