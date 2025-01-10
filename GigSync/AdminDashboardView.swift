import SwiftUI

struct AdminDashboardView: View {
    let bandId: String
    
    var body: some View {
        List {
            NavigationLink(destination: GigManagementView(bandId: bandId)) {
                DashboardRow(title: "Gigs", icon: "calendar")
            }
            
            NavigationLink(destination: SetlistManagementView(bandId: bandId)) {
                DashboardRow(title: "Setlists", icon: "music.note.list")
            }
            
            NavigationLink(destination: FinanceManagementView(bandId: bandId)) {
                DashboardRow(title: "Finances", icon: "dollarsign.circle")
            }
            
            NavigationLink(destination: MessagingView(bandId: bandId)) {
                DashboardRow(title: "Messages", icon: "message")
            }
            
            NavigationLink(destination: BandManagementView(bandId: bandId)) {
                DashboardRow(title: "Band Settings", icon: "gear")
            }
        }
        .navigationTitle("Admin Dashboard")
    }
}
