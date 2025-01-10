import SwiftUI
import FirebaseAuth
import FirebaseFirestore


enum BandRole: String, Codable {
    case member = "member"
    case admin = "admin"
}

struct Band: Identifiable, Codable {
    @DocumentID var id: String?
    let name: String
    var members: [String: BandMemberInfo]
    let createdAt: Date
    let imageUrl: String?
    let description: String?
    let genre: String
    let joinCode: String
    
    var memberCount: Int {
        members.count
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, members, createdAt, imageUrl, description, genre, joinCode
    }
    
    init(id: String, name: String, members: [String: BandMemberInfo], createdAt: Date, imageUrl: String?, description: String?, genre: String, joinCode: String) {
        self.id = id
        self.name = name
        self.members = members
        self.createdAt = createdAt
        self.imageUrl = imageUrl
        self.description = description
        self.genre = genre
        self.joinCode = joinCode
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        members = try container.decode([String: BandMemberInfo].self, forKey: .members)
        
        if let timestamp = try? container.decode(Timestamp.self, forKey: .createdAt) {
            createdAt = timestamp.dateValue()
        } else {
            createdAt = try container.decode(Date.self, forKey: .createdAt)
        }
        
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        genre = try container.decode(String.self, forKey: .genre)
        joinCode = try container.decode(String.self, forKey: .joinCode)
    }
}

struct BandMemberInfo: Codable {
    let role: BandRole
    let joinedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case role, joinedAt
    }
    
    init(role: BandRole, joinedAt: Date) {
        self.role = role
        self.joinedAt = joinedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let roleString = try? container.decode(String.self, forKey: .role),
           let decodedRole = BandRole(rawValue: roleString) {
            role = decodedRole
        } else {
            role = .member
        }
        
        if let timestamp = try? container.decode(Timestamp.self, forKey: .joinedAt) {
            joinedAt = timestamp.dateValue()
        } else {
            joinedAt = try container.decode(Date.self, forKey: .joinedAt)
        }
    }
}
