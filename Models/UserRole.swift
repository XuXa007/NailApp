import Foundation

enum UserRole: String, Codable, CaseIterable, Identifiable {
    case client = "CLIENT"
    case master = "MASTER"
    case salon = "SALON"
    
    var id: String { self.rawValue }
    
    var description: String {
        switch self {
        case .client: return "Клиент"
        case .master: return "Мастер маникюра"
        case .salon: return "Маникюрный салон"
        }
    }
    
    var icon: String {
        switch self {
        case .client: return "person.fill"
        case .master: return "person.fill.badge.plus"
        case .salon: return "building.2.fill"
        }
    }
}
