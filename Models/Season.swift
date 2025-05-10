enum Season: String, Codable, CaseIterable, Identifiable, CustomStringConvertible {
    case spring, summer, autumn, winter
    var id: String { rawValue }
    var description: String { rawValue.capitalized }
}
