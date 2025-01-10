//
//  Gig.swift
//  GigSync
//
//  Created by Jack Hodgy on 08/01/2025.
//


import Foundation

struct Gig: Identifiable, Codable {
    let id: String
    let title: String
    let date: Date
    let venue: String
    let notes: String
    let bandId: String
    let setlistId: String?
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
