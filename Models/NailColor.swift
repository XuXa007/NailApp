import SwiftUI

enum NailColor: String, CaseIterable, Identifiable, CustomStringConvertible {
    case pink, purple, red, blue, green, gray
    
    var id: String { rawValue }
    var description: String { rawValue.capitalized }
    
    //    var uiColor: Color {
    //        switch self {
    //        case .pink:   return .pink
    //        case .purple: return .purple
    //        case .red:    return .red
    //        case .blue:   return .blue
    //        case .green:  return .green
    //        case .gray:   return .gray
    //        }
    //    }
}

extension NailColor {
    var color: Color {
        switch self {
        case .red:    return .red
        case .pink:   return .pink
        case .blue:   return .blue
        case .green:  return .green
        case .purple: return .purple
            
            // case .black:  return .black
            // case .white:  return .white
            // case .yellow: return .yellow
            // case .orange: return .orange
            // case .brown:  return .brown
        case .gray:   return .gray
        @unknown default: return .gray
        }
    }
}
