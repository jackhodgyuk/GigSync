import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct MemberDashboardView: View {
    let bandId: String
    
    var body: some View {
        TabView {
            GigListView(bandId: bandId)
                .tabItem {
                    Label("Gigs", systemImage: "calendar")
                }
            
            SetlistView(bandId: bandId)
                .tabItem {
                    Label("Setlists", systemImage: "music.note.list")
                }
            
            FinanceView(bandId: bandId)
                .tabItem {
                    Label("Finances", systemImage: "dollarsign.circle")
                }
            
            MessagingView(bandId: bandId)
                .tabItem {
                    Label("Messages", systemImage: "message")
                }
        }
    }
}
