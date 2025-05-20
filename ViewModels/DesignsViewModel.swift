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
            let designs = try await ApiService.shared.fetchDesigns()
            allDesigns = designs
            filteredDesigns = designs
        } catch {
            print("Error loading designs:", error)
        }
    }
    
    func applyLocalFiltering() {
        let f = designFilter
        
        filteredDesigns = allDesigns.filter { design in
            let colorMatch = f.selectedColors.isEmpty ||
                design.nailColors.contains { color in
                    f.selectedColors.contains(color)
                }
            
            let styleMatch = f.selectedStyles.isEmpty ||
                (design.style != nil && f.selectedStyles.contains(design.style!))
            

            let seasonMatch = f.selectedSeasons.isEmpty ||
                (design.season != nil && f.selectedSeasons.contains(design.season!))
            

            let typeMatch = f.selectedTypes.isEmpty ||
                (design.type != nil && f.selectedTypes.contains(design.type!))
            
            return colorMatch && styleMatch && seasonMatch && typeMatch
        }
    }
}
