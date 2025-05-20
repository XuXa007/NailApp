enum NailLength: String, Codable, CaseIterable, Identifiable, CustomStringConvertible {
    case short, medium, long

    var id: String { rawValue }

    var description: String {
        switch self {
        case .short: return "Короткие"
        case .medium: return "Средние"
        case .long: return "Длинные"
        }
    }
}
