import SwiftUI
import FirebaseAuth

struct BandDetailView: View {
    let band: Band
    @State private var showingInviteCode = false
    @StateObject private var authManager = AuthenticationManager.shared
    
    var body: some View {
        List {
            Section("Band Info") {
                Text("Name: \(band.name)")
                Text("Genre: \(band.genre)")
                Text("Members: \(band.memberCount)")
                
                Button("Show Invite Code") {
                    showingInviteCode.toggle()
                }
                if showingInviteCode {
                    Text(band.joinCode)
                        .font(.title2)
                        .bold()
                }
            }
            
            Section("Upcoming Events") {
                NavigationLink("View Schedule") {
                    BandScheduleView(band: band)
                }
            }
            
            Section("Setlists") {
                NavigationLink("View Setlists") {
                    BandSetlistsView(band: band)
                }
            }
        }
        .navigationTitle(band.name)
        .navigationBarBackButtonHidden(true)
    }
}
