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
    
    var body: some View {
        List {
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
                            .onAppear {
                                print("Current join code: \(String(describing: viewModel.band?.joinCode))")
                            }
                        Spacer()
                        HStack {
                            Button(action: {
                                if let code = viewModel.band?.joinCode {
                                    UIPasteboard.general.string = code
                                    print("Copied code: \(code)")
                                }
                            }) {
                                Image(systemName: "doc.on.doc")
                            }
                            
                            if Auth.auth().currentUser?.email == "jackhodgy@thetysms.co.uk" {
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
            
            Section("Members (\(viewModel.bandMembers.count))") {
                ForEach(viewModel.bandMembers) { member in
                    UserRowView(member: member) { newRole in
                        viewModel.updateMemberRole(bandId: bandId, memberId: member.id, newRole: newRole)
                    }
                }
            }
        }
        .navigationTitle("Manage Members")
        .onAppear {
            print("View appeared with bandId: \(bandId)")
            viewModel.setupListeners(bandId: bandId)
        }
    }
}
