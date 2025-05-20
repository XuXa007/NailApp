enum NailStyle: String, CaseIterable, Identifiable, CustomStringConvertible {
    case classic, bold, pastel, matte, nude, dark

    var id: String { rawValue }

    var description: String {
        switch self {
        case .classic: return "Классический"
        case .bold: return "Яркий"
        case .pastel: return "Пастельный"
        case .matte: return "Матовый"
        case .nude: return "Нюд"
        case .dark: return "Тёмный"
        }
    }
}
