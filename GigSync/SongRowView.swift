//
//  SongRowView.swift
//  GigSync
//
//  Created by Jack Hodgy on 08/01/2025.
//


import SwiftUI

struct SongRowView: View {
    let song: Song
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(song.title)
                    .font(.headline)
                Text("\(song.duration) minutes")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if song.order >= 0 {
                Text("\(song.order + 1)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 24, height: 24)
                    .background(Color.secondary.opacity(0.2))
                    .clipShape(Circle())
            }
        }
        .padding(.vertical, 4)
    }
}
