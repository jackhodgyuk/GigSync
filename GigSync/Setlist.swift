import Foundation
import FirebaseFirestore

struct Setlist: Identifiable, Codable {
    @DocumentID var id: String?
    let name: String
    let bandId: String
    var songs: [Song]
    @ServerTimestamp var createdAt: Timestamp?
    
    var duration: Int {
        songs.reduce(0) { $0 + $1.duration }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case bandId
        case songs
        case createdAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        bandId = try container.decode(String.self, forKey: .bandId)
        songs = try container.decode([Song].self, forKey: .songs)
        createdAt = try container.decode(Timestamp.self, forKey: .createdAt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(bandId, forKey: .bandId)
        try container.encode(songs, forKey: .songs)
        try container.encode(createdAt, forKey: .createdAt)
    }
}

struct Song: Identifiable, Codable {
    let id: String
    let title: String
    let duration: Int
    var order: Int
}
