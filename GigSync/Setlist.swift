//
//  Setlist.swift
//  GigSync
//
//  Created by Jack Hodgy on 08/01/2025.
//


import Foundation

struct Setlist: Identifiable, Codable {
    let id: String
    let name: String
    let bandId: String
    var songs: [Song]
    let createdAt: Date
    
    var duration: Int {
        songs.reduce(0) { $0 + $1.duration }
    }
}

struct Song: Identifiable, Codable {
    let id: String
    let title: String
    let duration: Int
    var order: Int
}
