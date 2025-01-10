import SwiftUI
import FirebaseAuth

struct BandDashboardView: View {
    let band: Band
    @State private var userRole: BandRole = .member
    
    var body: some View {
        TabView {
            Group {
                if userRole == .admin {
                    adminManagerTabs
                } else {
                    memberTabs
                }
            }
        }
        .navigationTitle(band.name)
        .onAppear {
            loadUserRole()
        }
    }
    
    // MARK: - Tab Views
    private var adminManagerTabs: some View {
        Group {
            GigManagementView(bandId: band.id)
                .tabItem {
                    Label("Gigs", systemImage: "calendar")
                }
            
            SetlistManagementView(bandId: band.id)
                .tabItem {
                    Label("Setlists", systemImage: "music.note.list")
                }
            
            FinanceManagementView(bandId: band.id)
                .tabItem {
                    Label("Finances", systemImage: "dollarsign.circle")
                }
            
            ChatView(bandId: band.id)
                .tabItem {
                    Label("Chat", systemImage: "message")
                }
            
            if userRole == .admin {
                UserManagementView(bandId: band.id)
                    .tabItem {
                        Label("Members", systemImage: "person.2")
                    }
            }
        }
    }
    
    private var memberTabs: some View {
        Group {
            GigListView(bandId: band.id)
                .tabItem {
                    Label("Gigs", systemImage: "calendar")
                }
            
            SetlistView(bandId: band.id)
                .tabItem {
                    Label("Setlists", systemImage: "music.note.list")
                }
            
            ChatView(bandId: band.id)
                .tabItem {
                    Label("Chat", systemImage: "message")
                }
        }
    }
    
    // MARK: - Helper Methods
    private func loadUserRole() {
        if let currentUserId = Auth.auth().currentUser?.uid,
           let memberInfo = band.members[currentUserId] {
            userRole = memberInfo.role
        }
    }
}