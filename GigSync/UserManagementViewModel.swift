import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Combine

@MainActor
class UserManagementViewModel: ObservableObject {
    @Published var band: Band?
    @Published var bandMembers: [BandMember] = []
    @Published var isAdmin: Bool = false
    private let db = Firestore.firestore()
    private var listeners: [ListenerRegistration] = []
    
    func setupListeners(bandId: String) {
        guard !bandId.isEmpty else {
            print("Error: Empty bandId provided")
            return
        }
        
        print("Setting up listeners for band: \(bandId)")
        
        let bandListener = db.collection("bands").document(bandId)
            .addSnapshotListener { [weak self] snapshot, _ in
                guard let snapshot = snapshot, snapshot.exists else {
                    print("No snapshot found for bandId: \(bandId)")
                    return
                }
                Task { @MainActor in
                    do {
                        let band = try snapshot.data(as: Band.self)
                        self?.band = band
                        self?.checkAdminStatus(band: band)
                        await self?.updateMembers(from: band.members)
                        print("Successfully loaded band: \(band.name) with join code: \(band.joinCode)")
                    } catch {
                        print("Failed to decode band: \(error)")
                    }
                }
            }
        
        listeners.append(bandListener)
    }
    
    private func checkAdminStatus(band: Band) {
        if let currentUserId = Auth.auth().currentUser?.uid,
           let memberInfo = band.members[currentUserId] {
            isAdmin = memberInfo.role == .admin
        }
    }
    
    private func updateMembers(from members: [String: BandMemberInfo]) async {
        print("Starting to update members. Count in Firebase: \(members.count)")
        var updatedMembers: [BandMember] = []
        
        for (userId, memberInfo) in members {
            print("Processing member: \(userId)")
            if let userData = try? await UserService.shared.getUser(userId: userId) {
                let member = BandMember(
                    id: userId,
                    name: userData.name,
                    email: userData.email,
                    role: memberInfo.role.rawValue
                )
                updatedMembers.append(member)
                print("Successfully added member: \(member.name) with role: \(member.role)")
            }
        }
        
        let sortedMembers = updatedMembers.sorted { $0.name < $1.name }
        self.bandMembers = sortedMembers
        print("Final member count: \(sortedMembers.count)")
    }
    
    func updateMemberRole(bandId: String, memberId: String, newRole: String) {
        guard !bandId.isEmpty else { return }
        let ref = db.collection("bands").document(bandId)
        ref.updateData(["members.\(memberId).role": newRole])
    }
    
    func updateInviteCode(bandId: String, newCode: String) {
        guard !bandId.isEmpty,
              Auth.auth().currentUser?.email == "jackhodgyuk@gmail.com" else { return }
        let ref = db.collection("bands").document(bandId)
        ref.updateData(["joinCode": newCode])
    }
    
    func removeMember(bandId: String, memberId: String) {
        guard !bandId.isEmpty, isAdmin else { return }
        let ref = db.collection("bands").document(bandId)
        ref.updateData(["members.\(memberId)": FieldValue.delete()])
    }
    
    deinit {
        listeners.forEach { $0.remove() }
    }
}
