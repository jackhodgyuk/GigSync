import SwiftUI
import FirebaseFirestore

struct MemberSetlistView: View {
    let bandId: String
    @State private var setlists: [Setlist] = []
    
    var body: some View {
        List {
            if setlists.isEmpty {
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "music.note.list")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                            Text("No setlists available")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 20)
                }
            } else {
                ForEach(setlists) { setlist in
                    NavigationLink(destination: MemberSetlistDetailView(setlist: setlist)) {
                        HStack {
                            Image(systemName: "music.note.list")
                                .foregroundColor(.blue)
                                .imageScale(.large)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(setlist.name)
                                    .font(.headline)
                                HStack {
                                    Image(systemName: "music.note")
                                        .imageScale(.small)
                                    Text("\(setlist.songs.count) songs")
                                    Image(systemName: "clock")
                                        .imageScale(.small)
                                    Text("\(setlist.duration) min")
                                }
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle("Setlists")
        .onAppear {
            setupSetlistsListener()
        }
    }
    
    private func setupSetlistsListener() {
        Firestore.firestore().collection("setlists")
            .whereField("bandId", isEqualTo: bandId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                setlists = documents.compactMap { try? $0.data(as: Setlist.self) }
            }
    }
}

struct MemberSetlistDetailView: View {
    let setlist: Setlist
    
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
                            Text("No songs in this setlist")
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
                }
            } header: {
                Text("Songs")
                    .font(.headline)
            }
        }
        .navigationTitle(setlist.name)
        .animation(.easeInOut, value: setlist.songs)
    }
}
