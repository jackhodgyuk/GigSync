//
//  GigHeroView.swift
//  GigSync
//
//  Created by Jack Hodgy on 13/01/2025.
//

import SwiftUI

struct GigHeroView: View {
    let title: String
    let date: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
            
            VStack(spacing: 12) {
                Text(title)
                    .font(.title.bold())
                    .foregroundColor(.white)
                Text(date)
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding()
        }
        .frame(height: 200)
        .shadow(radius: 5)
    }
}
