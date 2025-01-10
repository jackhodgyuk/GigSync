import Foundation

struct BandMember: Identifiable, Codable {
    let id: String
    let name: String
    let email: String
    let role: String
    
    var isAdmin: Bool {
        role == "admin"
    }
    
    var isManager: Bool {
        role == "manager"
    }
    
    var canEditContent: Bool {
        isAdmin || isManager
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case role
    }
}
