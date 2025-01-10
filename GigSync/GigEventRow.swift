//
//  GigEventRow.swift
//  GigSync
//
//  Created by Jack Hodgy on 08/01/2025.
//


import SwiftUI

struct GigEventRow: View {
    let event: GigEvent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                EventTypeIcon(type: event.type)
                
                Text(event.title)
                    .font(.headline)
            }
            
            HStack {
                Image(systemName: "clock")
                Text(event.date, style: .time)
            }
            .foregroundColor(.secondary)
            
            if !event.location.isEmpty {
                HStack {
                    Image(systemName: "mappin")
                    Text(event.location)
                }
                .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
