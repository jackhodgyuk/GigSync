import SwiftUI
import FirebaseFirestore

struct SetlistView: View {
    let bandId: String
    @State private var setlists: [Setlist] = []
    @State private var showingAddSetlist = false
    
    private let db = Firestore.firestore()
    
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
                    NavigationLink(destination: SetlistDetailView(setlist: setlist, isAdmin: false)) {
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
                .onDelete(perform: deleteSetlist)
            }
        }
        .navigationTitle("Setlists")
        .toolbar {
            Button(action: { showingAddSetlist.toggle() }) {
                Image(systemName: "plus")
            }
        }
        .sheet(isPresented: $showingAddSetlist) {
            CreateSetlistView(eventId: "", bandId: bandId)
        }
        .onAppear {
            setupSetlistsListener()
        }
    }
    
    private func setupSetlistsListener() {
        db.collection("setlists")
            .whereField("bandId", isEqualTo: bandId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                setlists = documents.compactMap { try? $0.data(as: Setlist.self) }
            }
    }
    
    private func deleteSetlist(at offsets: IndexSet) {
        Task {
            for index in offsets {
                let setlist = setlists[index]
                if let id = setlist.id {
                    try? await db.collection("setlists").document(id).delete()
                }
            }
        }
    }
}
