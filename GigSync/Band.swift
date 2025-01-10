import Foundation
import FirebaseFirestore

struct Band: Identifiable, Codable {
    let id: String
    let name: String
    var members: [String: MemberInfo]
    let createdAt: Date
    let imageUrl: String?
    let description: String?
    let genre: String
    let joinCode: String
    
    var memberCount: Int {
        members.count
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case members
        case createdAt
        case imageUrl
        case description
        case genre
        case joinCode
    }
}

struct MemberInfo: Codable {
    let role: String
    let joinedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case role
        case joinedAt
    }
}
