import Foundation
import UIKit

class CacheManager {
    static let shared = CacheManager()
    private init() {}
    
    func clearImageCache() {
        // Clear URLCache
        URLCache.shared.removeAllCachedResponses()
        
        // Clear NSCache used by AsyncImage
        let cache = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
        URLCache.shared = cache
        
        // Reset shared URLSession
        URLSession.shared.configuration.urlCache = cache
        
        print("✅ Image cache cleared")
    }
    
    func clearAppCaches() {
        // Clear image cache
        clearImageCache()
        
        // Clear UserDefaults cache if needed
        // (Keep server URL and essential settings)
        let serverURL = Config.baseURL
        
        // Clear all UserDefaults except critical settings
        let dictionary = UserDefaults.standard.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            if key != "server_url" {
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
        
        // Restore critical settings
        Config.setServerURL(serverURL)
        
        print("✅ App caches cleared")
    }
}
