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
                design.colors.contains { color in
                    f.selectedColors.contains { $0.rawValue.lowercased() == color.lowercased() }
                }
            
            let styleMatch = f.selectedStyles.isEmpty ||
                f.selectedStyles.contains { $0.rawValue.lowercased() == design.designType.lowercased() }
            
            let seasonMatch = f.selectedSeasons.isEmpty ||
                f.selectedSeasons.contains { $0.rawValue.lowercased() == design.occasion.lowercased() }
            
            let typeMatch = f.selectedTypes.isEmpty ||
                f.selectedTypes.contains { $0.rawValue.lowercased() == design.length.lowercased() }
            
            return colorMatch && styleMatch && seasonMatch && typeMatch
        }
    }
}
