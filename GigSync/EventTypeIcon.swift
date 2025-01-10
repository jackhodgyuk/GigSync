//
//  EventTypeIcon.swift
//  GigSync
//
//  Created by Jack Hodgy on 08/01/2025.
//


import SwiftUI

struct EventTypeIcon: View {
    let type: GigEvent.EventType
    
    var body: some View {
        Image(systemName: iconName)
            .foregroundColor(iconColor)
    }
    
    private var iconName: String {
        switch type {
        case .gig:
            return "music.note"
        case .rehearsal:
            return "music.mic"
        case .meeting:
            return "person.3"
        case .other:
            return "calendar"
        }
    }
    
    private var iconColor: Color {
        switch type {
        case .gig:
            return .blue
        case .rehearsal:
            return .green
        case .meeting:
            return .orange
        case .other:
            return .gray
        }
    }
}
