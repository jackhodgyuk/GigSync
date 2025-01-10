import SwiftUI
import FirebaseAuth

struct MainView: View {
    @StateObject private var authManager = AuthenticationManager.shared
    @State private var userBands: [Band] = []
    @State private var showingAuthSheet = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            VStack {
                if authManager.isAuthenticated {
                    if isLoading {
                        ProgressView()
                    } else {
                        List(userBands) { band in
                            NavigationLink {
                                BandDetailView(band: band)
                            } label: {
                                BandRowView(band: band)
                            }
                        }
                    }
                    
                    HStack {
                        NavigationLink {
                            CreateBandView()
                        } label: {
                            Text("Create Band")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        NavigationLink {
                            JoinBandView()
                        } label: {
                            Text("Join Band")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                } else {
                    Button("Sign In") {
                        showingAuthSheet = true
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
                }
            }
            .navigationTitle("My Bands")
            .sheet(isPresented: $showingAuthSheet) {
                AuthView(isSignUp: false, completion: { success in
                    if success {
                        loadUserBands()
                    }
                })
            }
            .onAppear {
                if authManager.isAuthenticated {
                    loadUserBands()
                }
            }
        }
    }
    
    private func loadUserBands() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        
        Task {
            do {
                userBands = try await BandService.shared.getUserBands(userId: userId)
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}
