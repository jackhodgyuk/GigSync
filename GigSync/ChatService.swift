import FirebaseFirestore
import UIKit

class ChatService {
    static let shared = ChatService()
    private let db = Firestore.firestore()
    private let imgurClientId = "7216478b1aa86b7"
    
    func sendMessage(content: String, bandId: String, senderId: String) async throws {
        let userSnapshot = try await db.collection("users").document(senderId).getDocument()
        guard let userData = userSnapshot.data(),
              let senderName = userData["name"] as? String else { return }
        
        let messageData: [String: Any] = [
            "content": content,
            "senderId": senderId,
            "senderName": senderName,
            "timestamp": Timestamp(date: Date()),
            "bandId": bandId,
            "type": "text"
        ]
        
        try await db.collection("messages").addDocument(data: messageData)
    }
    
    func sendImage(imageData: Data, bandId: String, senderId: String) async throws {
        print("📸 Starting image upload, size: \(imageData.count) bytes")
        
        let userSnapshot = try await db.collection("users").document(senderId).getDocument()
        guard let userData = userSnapshot.data(),
              let senderName = userData["name"] as? String else {
            print("⚠️ Failed to get user data")
            return
        }
        
        print("🗜 Compressing image...")
        let compressedData = compressImage(imageData)
        print("✅ Compressed to: \(compressedData.count) bytes")
        
        print("☁️ Uploading to Imgur...")
        let imageUrl = try await uploadToImgur(compressedData)
        print("🎯 Image uploaded! URL: \(imageUrl)")
        
        let messageData: [String: Any] = [
            "imageUrl": imageUrl,
            "senderId": senderId,
            "senderName": senderName,
            "timestamp": Timestamp(date: Date()),
            "bandId": bandId,
            "type": "image"
        ]
        
        try await db.collection("messages").addDocument(data: messageData)
        print("✨ Image message saved to Firestore")
    }
    func clearAllMessages(bandId: String) async throws {
        let messagesRef = db.collection("messages")
        let bandMessages = try await messagesRef
            .whereField("bandId", isEqualTo: bandId)
            .getDocuments()
        
        for message in bandMessages.documents {
            try await message.reference.delete()
        }
    }

    private func uploadToImgur(_ imageData: Data) async throws -> String {
        var request = URLRequest(url: URL(string: "https://api.imgur.com/3/image")!)
        request.httpMethod = "POST"
        request.setValue("Client-ID \(imgurClientId)", forHTTPHeaderField: "Authorization")
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let (data, httpResponse) = try await URLSession.shared.data(for: request)
        print("📡 Imgur Response: \(httpResponse)")
        
        let imgurResponse = try JSONDecoder().decode(ImgurResponse.self, from: data)
        return imgurResponse.data.link
    }
    
    private func compressImage(_ data: Data) -> Data {
        guard let image = UIImage(data: data) else { return data }
        let maxSize: CGFloat = 1024
        let scale = min(maxSize/image.size.width, maxSize/image.size.height, 1)
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let compressedData = renderer.jpegData(withCompressionQuality: 0.6) { context in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        return compressedData
    }
    
    func deleteMessage(_ messageId: String) async throws {
        try await db.collection("messages").document(messageId).delete()
    }
}

struct ImgurResponse: Codable {
    let data: ImgurData
}

struct ImgurData: Codable {
    let link: String
}
