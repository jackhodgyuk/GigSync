import SwiftUI
import FirebaseFirestore

struct SetlistManagementView: View {
    @State private var setlists: [Setlist] = []
    @State private var showingAddSetlist = false
    let bandId: String
    
    var body: some View {
        NavigationView {
            List {
                ForEach(setlists) { setlist in
                    NavigationLink(destination: SetlistDetailView(setlist: setlist)) {
                        SetlistRowView(
                            setlist: setlist,
                            isSelected: false,
                            action: {}
                        )
                    }
                }
                .onDelete(perform: deleteSetlist)
            }
            .navigationTitle("Setlists")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSetlist.toggle() }) {
                        Image(systemName: "plus")
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
                guard let documents = snapshot?.documents else {
                    print("No setlist documents found")
                    return
                }
                
                setlists = documents.compactMap { document in
                    if let setlist = try? document.data(as: Setlist.self) {
                        print("Loaded setlist: \(setlist.name) with \(setlist.songs.count) songs")
                        return setlist
                    }
                    return nil
                }
                print("Total setlists loaded: \(setlists.count)")
            }
    }
    
    private func deleteSetlist(at offsets: IndexSet) {
        // Firebase deletion implementation coming next
    }
}
