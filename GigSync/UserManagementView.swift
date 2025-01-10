import SwiftUI
import FirebaseFirestore

@MainActor
struct UserManagementView: View {
    @State private var bandMembers: [BandMember] = []
    let bandId: String
    private let db = Firestore.firestore()
    
    var body: some View {
        List {
            ForEach(bandMembers) { member in
                UserRowView(member: member) { newRole in
                    updateMemberRole(memberId: member.id, newRole: newRole)
                }
            }
        }
        .navigationTitle("Manage Members")
        .onAppear {
            setupMembersListener()
        }
    }
    
    private func setupMembersListener() {
        db.collection("bands")
            .document(bandId)
            .addSnapshotListener { snapshot, error in
                guard let data = snapshot?.data(),
                      let members = data["members"] as? [String: [String: Any]] else { return }
                
                Task { @MainActor in
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
                    bandMembers = updatedMembers.sorted { $0.name < $1.name }
                }
            }
    }
    
    private func updateMemberRole(memberId: String, newRole: String) {
        Task {
            let updateData: [String: Any] = ["members.\(memberId).role": newRole]
            try? await db.collection("bands").document(bandId).updateData(updateData)
        }
    }
}
