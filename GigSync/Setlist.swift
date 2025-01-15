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
    
    init(id: String? = nil, name: String, bandId: String, songs: [Song] = [], createdAt: Timestamp? = nil) {
        self.id = id
        self.name = name
        self.bandId = bandId
        self.songs = songs
        self.createdAt = createdAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.bandId = try container.decode(String.self, forKey: .bandId)
        self.songs = try container.decode([Song].self, forKey: .songs)
        self.createdAt = try container.decodeIfPresent(Timestamp.self, forKey: .createdAt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(bandId, forKey: .bandId)
        try container.encode(songs, forKey: .songs)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
    }
}

struct Song: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let duration: Int
    var order: Int
    
    init(id: String = UUID().uuidString, title: String, duration: Int, order: Int = 0) {
        self.id = id
        self.title = title
        self.duration = duration
        self.order = order
    }
}
