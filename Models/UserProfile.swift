import Foundation

struct UserProfile: Codable {
    var id: Int
    var username: String
    var email: String
    var isGuest: Bool
    var favoriteDesigns: [Int]
    
    // Хранение текущего пользователя
    static var current: UserProfile?
    
    // Проверка авторизации
    static var isLoggedIn: Bool {
        return current != nil && !current!.isGuest
    }
    
    // Создание гостевого профиля
    static func createGuestProfile() -> UserProfile {
        return UserProfile(
            id: -1,
            username: "Гость",
            email: "",
            isGuest: true,
            favoriteDesigns: []
        )
    }
    
    // Добавление дизайна в избранное
    mutating func addToFavorites(designId: Int) {
        if !favoriteDesigns.contains(designId) {
            favoriteDesigns.append(designId)
        }
    }
    
    // Удаление дизайна из избранного
    mutating func removeFromFavorites(designId: Int) {
        favoriteDesigns.removeAll { $0 == designId }
    }
}
