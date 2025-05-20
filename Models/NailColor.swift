import SwiftUI

enum NailColor: String, CaseIterable, Identifiable, CustomStringConvertible {
    case pink, purple, red, blue, green, gray, burgundy, fuchsia, nude, mint, olive

    var id: String { rawValue }

    var description: String {
        switch self {
        case .pink: return "Розовый"
        case .purple: return "Фиолетовый"
        case .red: return "Красный"
        case .blue: return "Синий"
        case .green: return "Зелёный"
        case .gray: return "Серый"
        case .burgundy: return "Бордовый"
        case .fuchsia: return "Фуксия"
        case .nude: return "Нюд"
        case .mint: return "Мятный"
        case .olive: return "Оливковый"
        }
    }

    var color: Color {
        switch self {
        case .red:      return .red
        case .pink:     return .pink
        case .purple:   return .purple
        case .blue:     return .blue
        case .green:    return .green
        case .gray:     return .gray
        case .burgundy: return Color(red: 0.5, green: 0.0, blue: 0.13)
        case .fuchsia:  return Color.purple
        case .nude:     return Color(.systemPink).opacity(0.4)
        case .mint:     return Color.green.opacity(0.4)
        case .olive:    return Color(hue: 0.33, saturation: 0.2, brightness: 0.5)
        }
    }
}


//extension NailColor {
//    var color: Color {
//        switch self {
//        case .red:    return .red
//        case .pink:   return .pink
//        case .blue:   return .blue
//        case .green:  return .green
//        case .purple: return .purple
//            
//            // case .black:  return .black
//            // case .white:  return .white
//            // case .yellow: return .yellow
//            // case .orange: return .orange
//            // case .brown:  return .brown
//        case .gray:   return .gray
//        @unknown default: return .gray
//        }
//    }
//}
