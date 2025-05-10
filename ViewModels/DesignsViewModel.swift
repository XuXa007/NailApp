import Foundation
import SwiftUI

@MainActor
class DesignsViewModel: ObservableObject {
    @Published var allDesigns: [NailDesign] = []
    @Published var filteredDesigns: [NailDesign] = []
    @Published var designFilter = DesignFilter()
    @Published var isLoading = false

    func loadDesigns() async {
        isLoading = true
        defer { isLoading = false }

        do {
            //  URL с query-параметрами
            let designs = try await ApiService.shared.fetchDesigns(using: designFilter)
            allDesigns = designs
            filteredDesigns = designs
        } catch {
            print("Error loading designs:", error)
            applyLocalFiltering()
        }
    }

    func applyLocalFiltering() {
        let f = designFilter

        filteredDesigns = allDesigns.filter { d in
            // Цвета
            let colorMatch = f.selectedColors.isEmpty
                || !Set(d.nailColors).isDisjoint(with: f.selectedColors)

            // Стиль
            let styleMatch = f.selectedStyles.isEmpty
                || (d.style != nil && f.selectedStyles.contains(d.style!))

            // Сезон
            let seasonMatch = f.selectedSeasons.isEmpty
                || (d.season != nil && f.selectedSeasons.contains(d.season!))

            // Тип
            let typeMatch = f.selectedTypes.isEmpty
                || (d.type != nil && f.selectedTypes.contains(d.type!))

            // Ключевое слово
            let keywordMatch = f.keyword.isEmpty
                || d.name.localizedCaseInsensitiveContains(f.keyword)

            return colorMatch
                && styleMatch
                && seasonMatch
                && typeMatch
                && keywordMatch
        }
    }

}
