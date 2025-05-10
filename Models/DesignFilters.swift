import Foundation

struct DesignFilter {
    var selectedColors: Set<NailColor>   = []
    var selectedStyles: Set<NailStyle>   = []
    var selectedSeasons: Set<Season>     = []
    var selectedTypes: Set<DesignType>   = []
    var keyword: String                  = ""
}
