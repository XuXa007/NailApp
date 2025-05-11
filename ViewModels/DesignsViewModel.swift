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
            //  url c query
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
            let colorMatch = f.selectedColors.isEmpty
            || !Set(d.nailColors).isDisjoint(with: f.selectedColors)
            let styleMatch = f.selectedStyles.isEmpty
            || (d.style != nil && f.selectedStyles.contains(d.style!))
            let seasonMatch = f.selectedSeasons.isEmpty
            || (d.season != nil && f.selectedSeasons.contains(d.season!))
            let typeMatch = f.selectedTypes.isEmpty
            || (d.type != nil && f.selectedTypes.contains(d.type!))
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
