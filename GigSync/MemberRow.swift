//
//  MemberRow.swift
//  GigSync
//
//  Created by Jack Hodgy on 08/01/2025.
//


import SwiftUI

struct MemberRow: View {
    let userId: String
    let role: String
    let onDelete: () -> Void
    @State private var userName: String = "Loading..."
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(userName)
                    .font(.headline)
                Text(role.capitalized)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if role != "admin" {
                Button(role: .destructive, action: onDelete) {
                    Image(systemName: "person.fill.xmark")
                }
            }
        }
        .onAppear {
            loadUserName()
        }
    }
    
    private func loadUserName() {
        Task {
            if let user = try? await UserService.shared.getUser(userId: userId) {
                userName = user.name
            }
        }
    }
}
