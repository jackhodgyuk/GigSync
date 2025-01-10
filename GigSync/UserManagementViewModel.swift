//
//  UserManagementViewModel.swift
//  GigSync
//
//  Created by Jack Hodgy on 10/01/2025.
//


import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Combine

@MainActor
class UserManagementViewModel: ObservableObject {
    @Published var band: Band?
    @Published var bandMembers: [BandMember] = []
    private let db = Firestore.firestore()
    private var listeners: [ListenerRegistration] = []
    
    func setupListeners(bandId: String) {
        guard !bandId.isEmpty else { return }
        print("Setting up listeners for band: \(bandId)")
        
        let bandListener = db.collection("bands").document(bandId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let snapshot = snapshot, snapshot.exists else { return }
                self?.band = try? snapshot.data(as: Band.self)
                print("Band data updated successfully")
            }
        
        let membersListener = db.collection("bands").document(bandId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let data = snapshot?.data(),
                      let members = data["members"] as? [String: [String: Any]] else { return }
                
                Task { @MainActor in
                    await self?.updateMembers(from: members)
                    print("Members updated successfully")
                }
            }
        
        listeners.append(contentsOf: [bandListener, membersListener])
    }
    
    private func updateMembers(from members: [String: [String: Any]]) async {
        var updatedMembers: [BandMember] = []
        for (userId, memberData) in members {
            if let userData = try? await UserService.shared.getUser(userId: userId) {
                let role = memberData["role"] as? String ?? "member"
                updatedMembers.append(BandMember(
                    id: userId,
                    name: userData.name,
                    email: userData.email,
                    role: role
                ))
            }
        }
        self.bandMembers = updatedMembers.sorted { $0.name < $1.name }
    }
    
    func updateMemberRole(bandId: String, memberId: String, newRole: String) {
        guard !bandId.isEmpty else { return }
        Task {
            let updateData: [String: Any] = ["members.\(memberId).role": newRole]
            try? await db.collection("bands").document(bandId).updateData(updateData)
        }
    }
    
    func updateInviteCode(bandId: String, newCode: String) {
        guard !bandId.isEmpty,
              Auth.auth().currentUser?.email == "jackhodgy@thetysms.co.uk" else { return }
        
        Task {
            let updateData: [String: Any] = ["joinCode": newCode]
            try? await db.collection("bands").document(bandId).updateData(updateData)
        }
    }
    
    deinit {
        listeners.forEach { $0.remove() }
    }
}
