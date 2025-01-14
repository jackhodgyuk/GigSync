import FirebaseFirestore

struct Message: Identifiable, Codable {
    @DocumentID var id: String?
    let content: String?  // Optional for image messages
    let senderId: String
    let senderName: String
    let timestamp: Date
    let bandId: String
    let type: String?  // Optional for backward compatibility
    let imageUrl: String?
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case content
        case senderId
        case senderName
        case timestamp
        case bandId
        case type
        case imageUrl
    }
}
