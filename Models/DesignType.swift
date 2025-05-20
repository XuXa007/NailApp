enum DesignType: String, Codable, CaseIterable, Identifiable, CustomStringConvertible {
    case french, ombre, matte, glitter
    var id: String { rawValue }
    var description: String { rawValue.capitalized }
}


