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
    @State private var navigateToDashboard = false
    @State private var currentBand: Band?
    
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
                            .bold()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(inviteCode.count != 6 || isLoading)
            }
            .padding()
            .sheet(isPresented: $showingAuthSheet) {
                AuthView(isSignUp: false, completion: { success in
                    if success {
                        joinBand()
                    }
                })
            }
            .navigationDestination(isPresented: $navigateToDashboard) {
                if let band = currentBand {
                    BandDashboardView(band: band)
                        .navigationBarBackButtonHidden()
                }
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
        print("Starting join process with code: \(inviteCode)")
        
        Task {
            do {
                print("Validating invite code...")
                let bandId = try await BandInviteService.shared.validateInviteCode(inviteCode)
                print("Validated bandId: \(bandId)")
                
                print("Adding member to band...")
                try await BandService.shared.addMemberToBand(userId: Auth.auth().currentUser?.uid ?? "", bandId: bandId)
                print("Successfully added member to band")
                
                print("Loading user bands...")
                let bands = try await BandService.shared.getUserBands(userId: Auth.auth().currentUser?.uid ?? "")
                if let joinedBand = bands.first(where: { $0.id == bandId }) {
                    currentBand = joinedBand
                    navigateToDashboard = true
                }
                await authManager.loadUserBands()
                isLoading = false
            } catch {
                print("Join error: \(error)")
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}
