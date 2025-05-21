import Foundation

struct UserProfile: Codable {
    let id: String
    let username: String
    let email: String
    let role: UserRole
    var salonName: String?
    var address: String?
    
    enum UserRole: String, Codable {
        case client = "CLIENT"
        case master = "MASTER"
    }
    
    enum CodingKeys: String, CodingKey {
        case id, username, email, role, salonName, address
    }
    
    var isMaster: Bool {
        return role == .master
    }
}
