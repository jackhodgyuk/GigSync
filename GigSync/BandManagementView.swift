//
//  BandManagementView.swift
//  GigSync
//
//  Created by Jack Hodgy on 08/01/2025.
//


import SwiftUI
import FirebaseFirestore

struct BandManagementView: View {
    let bandId: String
    @State private var band: Band?
    @State private var showingAddMember = false
    @State private var showingEditBand = false
    
    var body: some View {
        List {
            Section("Band Info") {
                if let band = band {
                    BandInfoRow(title: "Name", value: band.name)
                    BandInfoRow(title: "Members", value: "\(band.memberCount)")
                    BandInfoRow(title: "Created", value: band.createdAt.formatted(date: .abbreviated, time: .omitted))
                }
            }
            
            Section("Members") {
                if let members = band?.members {
                    ForEach(Array(members.keys), id: \.self) { userId in
                        if let member = members[userId] {
                            MemberRow(userId: userId, role: member.role) {
                                removeMember(userId: userId)
                            }
                        }
                    }
                }
                
                Button(action: { showingAddMember.toggle() }) {
                    Label("Add Member", systemImage: "person.badge.plus")
                }
            }
            
            Section("Danger Zone") {
                Button(role: .destructive) {
                    // Implement delete band functionality
                } label: {
                    Label("Delete Band", systemImage: "trash")
                }
            }
        }
        .navigationTitle("Band Settings")
        .sheet(isPresented: $showingAddMember) {
            AddMemberView(bandId: bandId)
        }
        .onAppear {
            loadBandData()
        }
    }
    
    private func loadBandData() {
        let db = Firestore.firestore()
        db.collection("bands").document(bandId)
            .addSnapshotListener { snapshot, error in
                guard let document = snapshot else { return }
                band = try? document.data(as: Band.self)
            }
    }
    
    private func removeMember(userId: String) {
        Task {
            try? await BandService.shared.removeMemberFromBand(userId: userId, bandId: bandId)
        }
    }
}
