//
//  Message.swift
//  GigSync
//
//  Created by Jack Hodgy on 08/01/2025.
//


import FirebaseFirestore

struct Message: Identifiable, Codable {
    let id: String
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
}
