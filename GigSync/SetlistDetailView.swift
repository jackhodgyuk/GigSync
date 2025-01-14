import SwiftUI
import FirebaseFirestore

struct SetlistDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var setlist: Setlist
    @State private var showingAddSong = false
    @State private var isEditing = false
    
    init(setlist: Setlist) {
        _setlist = State(initialValue: setlist)
    }
    
    var body: some View {
        List {
            Section(header: Text("Details")) {
                HStack {
                    Text("Total Duration:")
                    Spacer()
                    Text("\(setlist.duration) minutes")
                        .foregroundColor(.secondary)
                }
            }
            
            Section(header: Text("Songs")) {
                if setlist.songs.isEmpty {
                    Text("Add your first song")
                        .foregroundColor(.secondary)
                        .italic()
                } else {
                    ForEach(setlist.songs) { song in
                        SongRowView(song: song)
                    }
                    .onMove(perform: moveSongs)
                    .onDelete(perform: deleteSong)
                }
            }
        }
        .navigationTitle(setlist.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddSong.toggle() }) {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if !setlist.songs.isEmpty {
                    EditButton()
                }
            }
        }
        .sheet(isPresented: $showingAddSong) {
            AddSongView { song in
                addSong(song)
            }
        }
        .onAppear {
            setupSetlistListener()
        }
        .onChange(of: setlist.songs.isEmpty) { oldValue, newValue in
            if newValue {
                Task {
                    if let id = setlist.id {
                        try? await Firestore.firestore().collection("setlists").document(id).delete()
                        await MainActor.run {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
    
    private func moveSongs(from source: IndexSet, to destination: Int) {
        var updatedSongs = setlist.songs
        updatedSongs.move(fromOffsets: source, toOffset: destination)
        
        for (index, _) in updatedSongs.enumerated() {
            updatedSongs[index].order = index
        }
        
        Task {
            if let id = setlist.id {
                try? await SetlistService.shared.updateSongOrder(
                    setlistId: id,
                    songs: updatedSongs
                )
            }
        }
    }
    
    private func deleteSong(at offsets: IndexSet) {
        Task {
            if let id = setlist.id {
                try? await SetlistService.shared.removeSongs(
                    from: id,
                    at: offsets
                )
            }
        }
    }
    
    private func addSong(_ song: Song) {
        Task {
            if let id = setlist.id {
                try? await SetlistService.shared.addSong(
                    to: id,
                    song: song
                )
            }
        }
    }
    
    private func setupSetlistListener() {
        guard let setlistId = setlist.id, !setlistId.isEmpty else { return }
        
        Firestore.firestore().collection("setlists")
            .document(setlistId)
            .addSnapshotListener { snapshot, error in
                guard let document = snapshot else { return }
                if let updatedSetlist = try? document.data(as: Setlist.self) {
                    Task { @MainActor in
                        withAnimation {
                            setlist = updatedSetlist
                        }
                    }
                }
            }
    }
}
