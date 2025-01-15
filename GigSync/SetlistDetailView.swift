import SwiftUI
import FirebaseFirestore

struct SetlistDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var setlist: Setlist
    @State private var showingAddSong = false
    @State private var isEditing = false
    private let documentId: String
    let isAdmin: Bool
    
    init(setlist: Setlist, isAdmin: Bool) {
        _setlist = State(initialValue: setlist)
        self.documentId = setlist.id ?? ""
        self.isAdmin = isAdmin
        print("📝 Initializing SetlistDetailView with setlist: \(setlist.name) [DocumentID: \(documentId)]")
    }
    
    var body: some View {
        List {
            Section {
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.blue)
                            .imageScale(.large)
                        Text("\(setlist.duration) minutes")
                            .font(.headline)
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    
                    if !setlist.songs.isEmpty {
                        HStack {
                            Image(systemName: "music.note.list")
                                .foregroundColor(.blue)
                                .imageScale(.large)
                            Text("\(setlist.songs.count) songs")
                                .font(.headline)
                            Spacer()
                        }
                    }
                }
                .listRowBackground(Color.clear)
            }
            
            Section {
                if setlist.songs.isEmpty {
                    HStack {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "music.note")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                            Text("No songs added yet")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 20)
                } else {
                    ForEach(setlist.songs) { song in
                        SongRowView(song: song)
                            .transition(.slide)
                    }
                    .onMove(perform: isAdmin ? moveSongs : nil)
                    .onDelete(perform: isAdmin ? deleteSong : nil)
                }
            } header: {
                HStack {
                    Text("Songs")
                        .font(.headline)
                    Spacer()
                    if isAdmin {
                        Button(action: { showingAddSong.toggle() }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .navigationTitle(setlist.name)
        .toolbar {
            if isAdmin && !setlist.songs.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
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
        .animation(.easeInOut, value: setlist.songs)
    }
    
    private func moveSongs(from source: IndexSet, to destination: Int) {
        var updatedSongs = setlist.songs
        updatedSongs.move(fromOffsets: source, toOffset: destination)
        
        for (index, _) in updatedSongs.enumerated() {
            updatedSongs[index].order = index
        }
        
        Task {
            try? await SetlistService.shared.updateSongOrder(
                setlistId: documentId,
                songs: updatedSongs
            )
        }
    }
    
    private func deleteSong(at offsets: IndexSet) {
        Task {
            try? await SetlistService.shared.removeSongs(
                from: documentId,
                at: offsets
            )
        }
    }
    
    private func addSong(_ song: Song) {
        guard !documentId.isEmpty else { return }
        Task {
            try? await SetlistService.shared.addSong(
                to: documentId,
                song: song
            )
        }
    }
    
    private func setupSetlistListener() {
        guard !documentId.isEmpty else { return }
        
        let setlistRef = Firestore.firestore().collection("setlists").document(documentId)
        
        setlistRef.addSnapshotListener { snapshot, error in
            guard let document = snapshot,
                  let updatedSetlist = try? document.data(as: Setlist.self)
            else { return }
            
            Task { @MainActor in
                withAnimation(.easeInOut) {
                    setlist = updatedSetlist
                }
            }
        }
    }
}
