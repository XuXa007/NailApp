// Models/NailColor.swift
import SwiftUI

enum NailColor: String, CaseIterable, Identifiable, CustomStringConvertible {
    case pink, purple, red, blue, green, gray

    var id: String { rawValue }
    var description: String { rawValue.capitalized }

    // настоящая SwiftUI-цветовая константа
    var uiColor: Color {
        switch self {
        case .pink:   return .pink
        case .purple: return .purple
        case .red:    return .red
        case .blue:   return .blue
        case .green:  return .green
        case .gray:   return .gray
        }
    }
}

