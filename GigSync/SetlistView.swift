import SwiftUI
import FirebaseFirestore

struct SetlistView: View {
    let bandId: String
    @State private var setlists: [Setlist] = []
    @State private var showingAddSetlist = false
    
    private let db = Firestore.firestore()
    
    var body: some View {
        List {
            ForEach(setlists) { setlist in
                NavigationLink(destination: SetlistDetailView(setlist: setlist)) {
                    SetlistRow(setlist: setlist, isSelected: false) {
                        // Empty action as this is just for navigation
                    }
                }
            }
            .onDelete(perform: deleteSetlist)
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
