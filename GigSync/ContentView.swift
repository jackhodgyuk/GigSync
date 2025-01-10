import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @StateObject private var authManager = AuthenticationManager.shared
    @State private var isLoading = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                if isLoading {
                    loadingView
                } else {
                    Group {
                        if authManager.isAuthenticated {
                            // Direct straight to BandSelectionView since you have bands
                            BandSelectionView()
                                .navigationBarBackButtonHidden()
                        } else {
                            WelcomeView()
                        }
                    }
                }
            }
        }
        .task {
            authManager.isAuthenticated = Auth.auth().currentUser != nil
            
            if authManager.isAuthenticated {
                print("Loading user bands...")
                await authManager.loadUserBands()
                print("Bands loaded: \(authManager.userBands.count)")
            }
            
            isLoading = false
        }
    }
    
    private var loadingView: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            ProgressView()
                .scaleEffect(1.5)
        }
    }
}
