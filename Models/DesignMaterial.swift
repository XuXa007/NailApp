enum DesignMaterial: String, CaseIterable, Identifiable, CustomStringConvertible {
    case gel, acrylic

    var id: String { rawValue }

    var description: String {
        switch self {
        case .gel: return "Гель"
        case .acrylic: return "Акрил"
        }
    }
}
