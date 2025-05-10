import Foundation

@MainActor
class FavoritesViewModel: ObservableObject {
    /// Список избранных дизайнов
    @Published private(set) var favorites: [NailDesign] = []
    
    /// Добавить/убрать дизайн из избранного
    func toggle(_ design: NailDesign) {
        if isFavorite(design) {
            // убрать
            favorites.removeAll { $0.id == design.id }
        } else {
            // добавить
            favorites.append(design)
        }
    }
    
    /// Проверить, есть ли уже в избранном
    func isFavorite(_ design: NailDesign) -> Bool {
        favorites.contains { $0.id == design.id }
    }
}
