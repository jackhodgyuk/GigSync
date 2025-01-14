import FirebaseFirestore

class ChatService {
    static let shared = ChatService()
    private let db = Firestore.firestore()
    
    func sendMessage(content: String, bandId: String, senderId: String) async throws {
        let userSnapshot = try await db.collection("users").document(senderId).getDocument()
        guard let userData = userSnapshot.data(),
              let senderName = userData["name"] as? String else { return }
        
        let messageData: [String: Any] = [
            "content": content,
            "senderId": senderId,
            "senderName": senderName,
            "timestamp": Timestamp(date: Date()),
            "bandId": bandId
        ]
        
        try await db.collection("messages").addDocument(data: messageData)
    }
    
    func deleteMessage(_ messageId: String) async throws {
        try await db.collection("messages").document(messageId).delete()
    }
}
