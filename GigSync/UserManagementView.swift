import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Combine

@MainActor
struct UserManagementView: View {
    let bandId: String
    @StateObject private var viewModel = UserManagementViewModel()
    @State private var isEditingInviteCode = false
    @State private var newInviteCode = ""
    @State private var showDeleteConfirmation = false
    @State private var memberToDelete: BandMember?
    
    var body: some View {
        List {
            if viewModel.isAdmin {
                Section("Invite Code") {
                    HStack {
                        if isEditingInviteCode {
                            TextField("New Code", text: $newInviteCode)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Button("Save") {
                                viewModel.updateInviteCode(bandId: bandId, newCode: newInviteCode)
                                isEditingInviteCode = false
                            }
                        } else {
                            Text(viewModel.band?.joinCode ?? "Loading...")
                                .font(.title2)
                                .bold()
                            
                            Spacer()
                            
                            HStack {
                                Button(action: {
                                    if let code = viewModel.band?.joinCode {
                                        UIPasteboard.general.string = code
                                    }
                                }) {
                                    Image(systemName: "doc.on.doc")
                                }
                                
                                if viewModel.isAdmin {
                                    Button(action: {
                                        newInviteCode = viewModel.band?.joinCode ?? ""
                                        isEditingInviteCode = true
                                    }) {
                                        Image(systemName: "pencil")
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            Section("Members (\(viewModel.bandMembers.count))") {
                ForEach(viewModel.bandMembers) { member in
                    UserRowView(
                        member: member,
                        isAdmin: viewModel.isAdmin,
                        onRoleChange: { newRole in
                            viewModel.updateMemberRole(bandId: bandId, memberId: member.id, newRole: newRole)
                        },
                        onDelete: {
                            memberToDelete = member
                            showDeleteConfirmation = true
                        }
                    )
                }
            }
        }
        .navigationTitle("Manage Members")
        .onAppear {
            viewModel.setupListeners(bandId: bandId)
        }
        .alert("Remove Member", isPresented: $showDeleteConfirmation, presenting: memberToDelete) { member in
            Button("Remove", role: .destructive) {
                viewModel.removeMember(bandId: bandId, memberId: member.id)
            }
            Button("Cancel", role: .cancel) {}
        } message: { member in
            Text("Are you sure you want to remove \(member.name)?")
        }
    }
}
