import SwiftUI
import FirebaseAuth

struct JoinBandFlow: View {
    @State private var inviteCode = ""
    @State private var isJoining = false
    @State private var showError = false
    @State private var errorMessage = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Enter Band Invite Code")
                    .font(.title2)
                    .bold()
                
                TextField("INVITE CODE", text: $inviteCode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .textInputAutocapitalization(.characters)
                    .onChange(of: inviteCode) { oldValue, newValue in
                        inviteCode = newValue.uppercased()
                    }
                
                Button(action: joinBand) {
                    if isJoining {
                        ProgressView()
                    } else {
                        Text("Join Band")
                            .bold()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(inviteCode.count != 6 || isJoining)
            }
            .padding()
            .navigationBarItems(trailing: Button("Cancel") { dismiss() })
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func joinBand() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        isJoining = true
        
        Task {
            do {
                let bandId = try await BandInviteService.shared.validateInviteCode(inviteCode)
                try await BandService.shared.addMemberToBand(userId: userId, bandId: bandId)
                isJoining = false
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
                isJoining = false
            }
        }
    }
}
