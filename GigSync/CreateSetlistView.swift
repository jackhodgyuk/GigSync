import SwiftUI
import FirebaseFirestore

struct CreateSetlistView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var selectedSongs: Set<String> = []
    @State private var songs: [Song] = []
    @State private var isLoading = false
    let eventId: String
    let bandId: String
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Setlist Details")) {
                    TextField("Setlist Name", text: $name)
                }
                
                Section(header: Text("Select Songs")) {
                    if songs.isEmpty {
                        Text("No songs available")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(songs) { song in
                            SongSelectionRow(
                                song: song,
                                isSelected: selectedSongs.contains(song.id)
                            ) {
                                toggleSongSelection(song.id)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Create Setlist")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Create") { createSetlist() }
                    .disabled(name.isEmpty || selectedSongs.isEmpty || isLoading)
            )
            .onAppear {
                loadSongs()
            }
        }
    }
    
    private func loadSongs() {
        Task {
            if let bandSongs = try? await SongService.shared.getSongs(bandId: bandId) {
                await MainActor.run {
                    songs = bandSongs
                }
            }
        }
    }
    
    private func toggleSongSelection(_ songId: String) {
        if selectedSongs.contains(songId) {
            selectedSongs.remove(songId)
        } else {
            selectedSongs.insert(songId)
        }
    }
    
    private func createSetlist() {
        isLoading = true
        let selectedSongsList = songs.filter { selectedSongs.contains($0.id) }
            .enumerated()
            .map { index, song in
                Song(id: song.id, title: song.title, duration: song.duration, order: index)
            }
        
        Task {
            do {
                let setlistId = try await SetlistService.shared.createSetlist(
                    name: name,
                    songs: selectedSongsList,
                    bandId: bandId
                )
                
                if !eventId.isEmpty {
                    try await BandService.shared.assignSetlist(setlistId, to: eventId)
                }
                
                await MainActor.run {
                    isLoading = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
}
