import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Network

struct CreateBandView: View {
    @StateObject private var authManager = AuthenticationManager.shared
    @StateObject private var networkMonitor = NetworkMonitor.shared
    @State private var bandName = ""
    @State private var genre = ""
    @State private var inviteCode = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var navigateToBandDashboard = false
    @State private var createdBand: Band?
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Band Name", text: $bandName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Genre", text: $genre)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if !inviteCode.isEmpty {
                VStack {
                    Text("Your band invite code:")
                        .font(.headline)
                    Text(inviteCode)
                        .font(.title)
                        .bold()
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
            }
            
            Button(action: createBand) {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Create Band")
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(bandName.isEmpty || isLoading || !networkMonitor.isConnected)
        }
        .padding()
        .navigationTitle("Create a Band")
        .navigationBarBackButtonHidden()
        .navigationDestination(isPresented: $navigateToBandDashboard) {
            if let band = createdBand {
                BandDashboardView(band: band)
                    .navigationBarBackButtonHidden()
            }
        }
        .alert("No Internet Connection", isPresented: .constant(!networkMonitor.isConnected)) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please check your internet connection and try again.")
        }
    }
    
    private func createBand() {
        guard networkMonitor.isConnected else { return }
        guard let userId = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let bandId = try await BandService.shared.createBand(
                    name: bandName,
                    genre: genre
                )
                
                let memberInfo = MemberInfo(role: "admin", joinedAt: Date())
                try await BandService.shared.addMemberToBand(userId: userId, bandId: bandId)
                
                let newBand = Band(
                    id: bandId,
                    name: bandName,
                    members: [userId: memberInfo],
                    createdAt: Date(),
                    imageUrl: nil,
                    description: nil,
                    genre: genre,
                    joinCode: UUID().uuidString.prefix(6).uppercased()
                )
                
                await MainActor.run {
                    self.createdBand = newBand
                    self.inviteCode = newBand.joinCode
                    navigateToBandDashboard = true
                }
                await authManager.loadUserBands()
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}
