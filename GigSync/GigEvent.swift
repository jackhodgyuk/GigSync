//
//  GigEvent.swift
//  GigSync
//
//  Created by Jack Hodgy on 08/01/2025.
//


import Foundation

struct GigEvent: Identifiable, Codable {
    let id: String
    let title: String
    let date: Date
    let location: String
    let type: EventType
    let notes: String?
    let bandId: String
    let createdBy: String
    
    enum EventType: String, Codable, CaseIterable {
        case gig = "Gig"
        case rehearsal = "Rehearsal"
        case meeting = "Meeting"
        case other = "Other"
    }
}
