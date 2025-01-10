import SwiftUI
import FirebaseAuth

struct BandSelectionView: View {
    @StateObject private var authManager = AuthenticationManager.shared
    @State private var showCreateBand = false
    @State private var isLoading = true
    @State private var loadingError: Error?
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.blue.opacity(0.1), .purple.opacity(0.1)]),
                             startPoint: .topLeading,
                             endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                Group {
                    if isLoading {
                        loadingView
                    } else {
                        bandsList
                    }
                }
            }
            .navigationTitle("My Bands")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    logoutButton
                }
            }
            .sheet(isPresented: $showCreateBand) {
                BandSetupView()
            }
            .task {
                withAnimation {
                    isLoading = true
                }
                await loadBandsWithRetry()
                withAnimation {
                    isLoading = false
                }
            }
            .refreshable {
                await loadBandsWithRetry()
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.blue)
            Text("Loading your bands...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
    
    private var bandsList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if authManager.userBands.isEmpty {
                    emptyStateView
                } else {
                    ForEach(authManager.userBands) { band in
                        NavigationLink(destination: BandDashboardView(band: band)) {
                            BandCard(band: band)
                                .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "music.note.list")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("No Bands Yet")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Create your first band to get started!")
                .foregroundColor(.secondary)
            
            Button(action: { showCreateBand = true }) {
                Text("Create Band")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 200)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
    
    private var logoutButton: some View {
        Button(action: handleLogout) {
            Image(systemName: "rectangle.portrait.and.arrow.right")
                .foregroundStyle(.red.gradient)
        }
    }
    
    private func handleLogout() {
        do {
            try Auth.auth().signOut()
            withAnimation {
                authManager.isAuthenticated = false
                authManager.userBands = []
            }
        } catch {
            print("Logout error: \(error.localizedDescription)")
        }
    }
    
    private func loadBandsWithRetry() async {
        for _ in 1...3 {
            await authManager.loadUserBands()
            if !authManager.userBands.isEmpty { break }
            try? await Task.sleep(nanoseconds: 1_000_000_000)
        }
    }
}

struct BandCard: View {
    let band: Band
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(LinearGradient(colors: [.blue, .purple],
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing))
                .frame(width: 50, height: 50)
                .overlay {
                    Text(band.name.prefix(1).uppercased())
                        .font(.title2.bold())
                        .foregroundColor(.white)
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(band.name)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text("\(band.memberCount) members • \(band.genre)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
