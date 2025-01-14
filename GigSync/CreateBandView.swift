import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Network

struct CreateBandView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authManager = AuthenticationManager.shared
    @StateObject private var networkMonitor = NetworkMonitor.shared
    @State private var bandName = ""
    @State private var genre = ""
    @State private var inviteCode = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @Environment(\.presentationMode) var presentationMode
    
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
        .alert("No Internet Connection", isPresented: .constant(!networkMonitor.isConnected)) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please check your internet connection and try again.")
        }
    }
    
    private func createBand() {
        guard networkMonitor.isConnected, Auth.auth().currentUser != nil else { return }
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let newBand = try await BandService.shared.createBandWithUser(
                    name: bandName,
                    genre: genre
                )
                
                await MainActor.run {
                    self.inviteCode = newBand.joinCode
                }
                await authManager.loadUserBands()
                isLoading = false
                
                // Dismiss both views
                await MainActor.run {
                    presentationMode.wrappedValue.dismiss()
                    dismiss()
                }
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}
