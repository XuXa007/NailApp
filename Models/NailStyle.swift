enum NailStyle: String, Codable, CaseIterable, Identifiable, CustomStringConvertible {
    case floral, geometric, minimal, abstract
    var id: String { rawValue }
    var description: String { rawValue.capitalized }
}
