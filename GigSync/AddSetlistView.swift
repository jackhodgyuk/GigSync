import SwiftUI
import FirebaseFirestore

struct AddSetlistView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var songs: [Song] = []
    @State private var showingAddSong = false
    @State private var isLoading = false
    let bandId: String
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Setlist Details")) {
                    TextField("Setlist Name", text: $name)
                }
                
                Section(header: Text("Songs")) {
                    ForEach(songs) { song in
                        SongRowView(song: song)
                    }
                    .onMove(perform: moveSongs)
                    
                    Button(action: { showingAddSong.toggle() }) {
                        Label("Add Song", systemImage: "plus")
                    }
                }
            }
            .navigationTitle("New Setlist")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") { saveSetlist() }
                    .disabled(name.isEmpty || isLoading)
            )
            .sheet(isPresented: $showingAddSong) {
                AddSongView(
                    setlistId: "",
                    bandId: bandId,
                    onSave: { song in
                        withAnimation {
                            songs.append(song)
                        }
                    }
                )
            }
        }
    }
    
    private func moveSongs(from source: IndexSet, to destination: Int) {
        songs.move(fromOffsets: source, toOffset: destination)
        updateSongOrder()
    }
    
    private func updateSongOrder() {
        for (index, _) in songs.enumerated() {
            songs[index].order = index
        }
    }
    
    private func saveSetlist() {
        isLoading = true
        Task {
            do {
                try await SetlistService.shared.createSetlist(
                    name: name,
                    songs: songs,
                    bandId: bandId
                )
                await MainActor.run {
                    isLoading = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                }
                print("Error saving setlist: \(error)")
            }
        }
    }
}
