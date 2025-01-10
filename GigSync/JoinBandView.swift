import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct JoinBandView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var authManager = AuthenticationManager.shared
    @State private var inviteCode = ""
    @State private var isLoading = false
    @State private var showingAuthSheet = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Enter Invite Code", text: $inviteCode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.allCharacters)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Button(action: handleJoinBand) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Join Band")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(inviteCode.isEmpty || isLoading)
            }
            .padding()
            .navigationTitle("Join a Band")
            .navigationBarItems(trailing: Button("Done") { dismiss() })
            .sheet(isPresented: $showingAuthSheet) {
                AuthView(isSignUp: false, completion: { success in
                    if success {
                        joinBand()
                    }
                })
            }
        }
    }
    
    private func handleJoinBand() {
        if !authManager.isAuthenticated {
            showingAuthSheet = true
        } else {
            joinBand()
        }
    }
    
    private func joinBand() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await BandService.shared.joinBand(code: inviteCode)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}
