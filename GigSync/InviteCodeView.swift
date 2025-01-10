//
//  InviteCodeView.swift
//  GigSync
//
//  Created by Jack Hodgy on 08/01/2025.
//


import SwiftUI

struct InviteCodeView: View {
    @State private var inviteCode: String
    @State private var isRefreshing = false
    let bandId: String
    
    init(bandId: String, initialCode: String) {
        self.bandId = bandId
        _inviteCode = State(initialValue: initialCode)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Band Invite Code")
                .font(.headline)
            
            Text(inviteCode)
                .font(.system(.title, design: .monospaced))
                .bold()
                .padding()
                .background(Color.secondary.opacity(0.2))
                .cornerRadius(10)
            
            Button(action: refreshCode) {
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                    Text("Generate New Code")
                }
            }
            .disabled(isRefreshing)
        }
        .padding()
    }
    
    private func refreshCode() {
        isRefreshing = true
        Task {
            if let newCode = try? await BandInviteService.shared.refreshInviteCode(bandId: bandId) {
                inviteCode = newCode
            }
            isRefreshing = false
        }
    }
}
