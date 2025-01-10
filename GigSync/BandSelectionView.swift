import SwiftUI
import FirebaseAuth

struct BandSelectionView: View {
    @StateObject private var authManager = AuthenticationManager.shared
    @State private var showCreateBand = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(authManager.userBands) { band in
                    NavigationLink(destination: BandDashboardView(band: band)) {
                        BandRowView(band: band)
                    }
                }
            }
            .navigationTitle("My Bands")
            .navigationBarItems(trailing: Button(action: handleLogout) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .foregroundColor(.red)
            })
            .onAppear {
                Task {
                    await authManager.loadUserBands()
                }
            }
        }
    }
    
    private func handleLogout() {
        try? Auth.auth().signOut()
        authManager.isAuthenticated = false
        authManager.userBands = []
    }
}
