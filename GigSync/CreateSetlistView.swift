import SwiftUI

struct CreateSetlistView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var selectedSongs: [Song] = []
    @State private var availableSongs: [Song] = []
    @State private var isLoading = false
    let eventId: String
    let bandId: String
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Setlist Details")) {
                    TextField("Setlist Name", text: $name)
                }
                
                Section(
                    header: Text("Songs"),
                    footer: Text("\(selectedSongs.count) songs selected")
                ) {
                    ForEach(availableSongs) { song in
                        SongSelectionRow(
                            song: song,
                            isSelected: selectedSongs.contains { $0.id == song.id }
                        ) {
                            toggleSong(song)
                        }
                    }
                }
            }
            .navigationTitle("Create Setlist")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") { saveSetlist() }
                    .disabled(name.isEmpty || selectedSongs.isEmpty || isLoading)
            )
            .onAppear {
                loadAvailableSongs()
            }
        }
    }
    
    private func toggleSong(_ song: Song) {
        if let index = selectedSongs.firstIndex(where: { $0.id == song.id }) {
            selectedSongs.remove(at: index)
        } else {
            selectedSongs.append(song)
        }
    }
    
    private func loadAvailableSongs() {
        Task {
            availableSongs = try await SongService.shared.getSongs(bandId: bandId)
        }
    }
    
    private func saveSetlist() {
        isLoading = true
        Task {
            do {
                try await SetlistService.shared.createSetlist(
                    name: name,
                    songs: selectedSongs,
                    bandId: bandId
                )
                isLoading = false
                dismiss()
            } catch {
                isLoading = false
            }
        }
    }
}
