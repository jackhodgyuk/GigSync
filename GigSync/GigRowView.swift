//
//  GigRowView.swift
//  GigSync
//
//  Created by Jack Hodgy on 08/01/2025.
//


import SwiftUI

struct GigRowView: View {
    let gig: Gig
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(gig.title)
                .font(.headline)
            
            HStack {
                Image(systemName: "mappin.circle.fill")
                Text(gig.venue)
            }
            .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: "calendar")
                Text(gig.formattedDate)
            }
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}
