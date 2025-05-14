import SwiftUI

enum NailColor: String, CaseIterable, Identifiable, CustomStringConvertible {
    case pink, purple, red, blue, green, gray
    
    var id: String { rawValue }
    var description: String {
        switch self {
        case .pink: return "Розовый"
        case .purple: return "Фиолетовый"
        case .red: return "Красный"
        case .blue: return "Синий"
        case .green: return "Зелёный"
        case .gray: return "Серый"
        }
    }
    
    var color: Color {
        switch self {
        case .red:    return .red
        case .pink:   return .pink
        case .blue:   return .blue
        case .green:  return .green
        case .purple: return .purple
        case .gray:   return .gray
        @unknown default: return .gray
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
