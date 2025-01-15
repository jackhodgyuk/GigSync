import SwiftUI
import FirebaseFirestore

struct SetlistManagementView: View {
    @State private var setlists: [Setlist] = []
    @State private var showingAddSetlist = false
    let bandId: String
    let isAdmin: Bool = true
    
    var body: some View {
        NavigationView {
            List {
                if setlists.isEmpty {
                    Section {
                        HStack {
                            Spacer()
                            VStack(spacing: 12) {
                                Image(systemName: "music.note.list")
                                    .font(.system(size: 40))
                                    .foregroundColor(.blue)
                                Text("Create your first setlist")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 20)
                    }
                } else {
                    ForEach(setlists) { setlist in
                        NavigationLink(destination: SetlistDetailView(setlist: setlist, isAdmin: true)) {
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSetlist.toggle() }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                            .imageScale(.large)
                    }
                }
            }
            .sheet(isPresented: $showingAddSetlist) {
                AddSetlistView(bandId: bandId)
            }
        }
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
                
                setlists = documents.compactMap { document in
                    try? document.data(as: Setlist.self)
                }
            }
    }
    
    private func deleteSetlist(at offsets: IndexSet) {
        Task {
            for index in offsets {
                if let id = setlists[index].id {
                    try? await SetlistService.shared.deleteSetlist(id)
                }
            }
        }
    }
}
