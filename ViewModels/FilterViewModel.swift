import SwiftUI

@MainActor
class FilterViewModel: ObservableObject {
    @Published var filter: DesignFilter
    
    let availableColors = NailColor.allCases
    let availableStyles = NailStyle.allCases
    let availableSeasons = Season.allCases
    let availableTypes = DesignType.allCases
    
    private let applyAction: (DesignFilter) -> Void
    
    init(filter: DesignFilter, apply: @escaping (DesignFilter) -> Void) {
        self.filter = filter
        self.applyAction = apply
    }
    
    func apply() {
        print("Applying filter: colors=\(filter.selectedColors.count), styles=\(filter.selectedStyles.count)")
        applyAction(filter)
    }
    
    func resetFilters() {
        filter = DesignFilter()
    }
}
