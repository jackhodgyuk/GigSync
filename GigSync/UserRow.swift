//
//  UserRow.swift
//  GigSync
//
//  Created by Jack Hodgy on 08/01/2025.
//


import SwiftUI

struct UserRow: View {
    let user: User
    let onAdd: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(user.name)
                    .font(.headline)
                Text(user.email)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: onAdd) {
                Image(systemName: "person.badge.plus")
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
    }
}
