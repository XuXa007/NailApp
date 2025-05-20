enum Season: String, CaseIterable, Identifiable, CustomStringConvertible {
    case spring, summer, autumn, winter, party, everyday

    var id: String { rawValue }

    var description: String {
        switch self {
        case .spring: return "Весна"
        case .summer: return "Лето"
        case .autumn: return "Осень"
        case .winter: return "Зима"
        case .party: return "Вечеринка"
        case .everyday: return "Каждый день"
        }
    }
}
