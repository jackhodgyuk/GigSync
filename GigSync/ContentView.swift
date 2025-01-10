import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @StateObject private var authManager = AuthenticationManager.shared
    
    var body: some View {
        NavigationStack {
            Group {
                if !authManager.isAuthenticated {
                    WelcomeView()
                } else if authManager.userBands.isEmpty {
                    BandSetupView()
                        .navigationBarBackButtonHidden()
                } else if let primaryBand = authManager.userBands.first {
                    BandDashboardView(band: primaryBand)
                        .navigationBarBackButtonHidden()
                        .ignoresSafeArea()
                }
            }
        }
        .onAppear {
            authManager.isAuthenticated = Auth.auth().currentUser != nil
        }
        .task {
            if Auth.auth().currentUser != nil {
                await authManager.loadUserBands()
            }
        }
    }
}
