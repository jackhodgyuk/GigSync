import SwiftUI

struct BandSetlistsView: View {
    let band: Band
    @State private var setlists: [Setlist] = []
    @State private var showingCreateSheet = false
    
    var body: some View {
        List {
            ForEach(setlists) { setlist in
                NavigationLink(destination: SetlistDetailView(setlist: setlist)) {
                    VStack(alignment: .leading) {
                        Text(setlist.name)
                            .font(.headline)
                        Text("\(setlist.songs.count) songs")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Setlists")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingCreateSheet = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingCreateSheet) {
            CreateSetlistView(eventId: "", bandId: band.id)
        }
        .onAppear {
            loadSetlists()
        }
    }
    
    private func loadSetlists() {
        Task {
            // Here's where we'll implement the setlist loading logic
            // setlists = try await BandService.shared.getBandSetlists(bandId: band.id)
        }
    }
}
