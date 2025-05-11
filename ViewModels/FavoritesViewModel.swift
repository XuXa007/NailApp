import SwiftUI

@MainActor
final class FavoritesViewModel: ObservableObject {
    @Published private(set) var items: [NailDesign] = []
    @Published var isLoading = false
    
    //  с сервера)
    func loadFavorites() async {
        isLoading = true
        defer { isLoading = false }
        do {
            items = try await ApiService.shared.fetchFavorites()
        } catch {
            print("Ошибка загрузки избранного:", error)
        }
    }
    
    // статус избранного и ресинхронизация
    func toggle(_ design: NailDesign) {
        Task {
            do {
                if items.contains(where: { $0.id == design.id }) {
                    try await ApiService.shared.removeFavorite(id: design.id)
                } else {
                    try await ApiService.shared.addFavorite(id: design.id)
                }
                await loadFavorites()
            } catch {
                print("Ошибка переключения избранного:", error)
            }
        }
    }
    
    // в избранном ли
    func isFavorite(_ design: NailDesign) -> Bool {
        items.contains(where: { $0.id == design.id })
    }
}
