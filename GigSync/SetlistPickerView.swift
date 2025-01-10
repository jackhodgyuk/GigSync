import SwiftUI

struct SetlistPickerView: View {
    let eventId: String
    let bandId: String
    @State private var setlists: [Setlist] = []
    @State private var selectedSetlistId: String?
    @State private var showingCreateSetlist = false
    
    var body: some View {
        List {
            Section {
                if setlists.isEmpty {
                    Text("No setlists available")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(setlists) { setlist in
                        SetlistRow(
                            setlist: setlist,
                            isSelected: selectedSetlistId == setlist.id,
                            onSelect: { assignSetlist(setlist.id) }
                        )
                    }
                }
            }
            
            Section {
                Button(action: { showingCreateSetlist.toggle() }) {
                    Label("Create New Setlist", systemImage: "plus")
                }
            }
        }
        .navigationTitle("Choose Setlist")
        .sheet(isPresented: $showingCreateSetlist) {
            CreateSetlistView(eventId: eventId, bandId: bandId)
        }
        .onAppear {
            loadSetlists()
            loadCurrentSetlist()
        }
    }
    
    private func loadSetlists() {
        Task {
            if let bandSetlists = try? await SetlistService.shared.getSetlists(bandId: bandId) {
                setlists = bandSetlists
            }
        }
    }
    
    private func loadCurrentSetlist() {
        Task {
            selectedSetlistId = try await BandService.shared.getEventSetlist(eventId)
        }
    }
    
    private func assignSetlist(_ setlistId: String) {
        Task {
            try await BandService.shared.assignSetlist(setlistId, to: eventId)
            selectedSetlistId = setlistId
        }
    }
}
