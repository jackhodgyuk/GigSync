//
//  Message.swift
//  GigSync
//
//  Created by Jack Hodgy on 08/01/2025.
//


import FirebaseFirestore

struct Message: Identifiable, Codable {
    @DocumentID var id: String?  // Changed to use DocumentID
    let content: String
    let senderId: String
    let senderName: String
    let timestamp: Date
    let bandId: String
    
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
    }
}
