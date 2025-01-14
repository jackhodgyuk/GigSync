//
//  Song.swift
//  GigSync
//
//  Created by Jack Hodgy on 14/01/2025.
//


import Foundation
import FirebaseFirestore

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
