import SwiftUI
import FirebaseAuth

struct BandDashboardView: View {
    let band: Band
    @State private var userRole: BandRole = .member
    
    var body: some View {
        TabView {
            if let bandId = band.id {
                if userRole == .admin {
                    adminManagerTabs(bandId: bandId)
                } else {
                    memberTabs(bandId: bandId)
                }
            }
        }
        .navigationTitle(band.name)
        .onAppear {
            loadUserRole()
            print("Band Dashboard loaded with ID: \(band.id ?? "none")")
        }
    }
    
    private func adminManagerTabs(bandId: String) -> some View {
        ForEach([
            ("Gigs", "calendar", AnyView(GigManagementView(bandId: bandId))),
            ("Setlists", "music.note.list", AnyView(SetlistManagementView(bandId: bandId))),
            ("Finances", "dollarsign.circle", AnyView(FinanceManagementView(bandId: bandId))),
            ("Chat", "message", AnyView(ChatView(bandId: bandId))),
            ("Members", "person.2", AnyView(UserManagementView(bandId: bandId)))
        ], id: \.0) { title, icon, view in
            view.tabItem {
                Label(title, systemImage: icon)
            }
        }
    }
    
    private func memberTabs(bandId: String) -> some View {
        ForEach([
            ("Gigs", "calendar", AnyView(GigListView(bandId: bandId, isAdmin: false))),
            ("Setlists", "music.note.list", AnyView(SetlistView(bandId: bandId))),
            ("Chat", "message", AnyView(ChatView(bandId: bandId)))
        ], id: \.0) { title, icon, view in
            view.tabItem {
                Label(title, systemImage: icon)
            }
        }
    }
    
    private func loadUserRole() {
        if let currentUserId = Auth.auth().currentUser?.uid,
           let memberInfo = band.members[currentUserId] {
            userRole = memberInfo.role
        } else {
            userRole = .member
        }
    }
}
