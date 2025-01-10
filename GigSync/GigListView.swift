import SwiftUI
import FirebaseFirestore

struct GigListView: View {
    let bandId: String
    @State private var gigs: [Gig] = []
    @State private var showingAddGig = false
    
    private let db = Firestore.firestore()
    
    var body: some View {
        List {
            ForEach(gigs) { gig in
                NavigationLink(destination: GigDetailView(gig: gig)) {
                    GigRowView(gig: gig)
                }
            }
        }
        .navigationTitle("Upcoming Gigs")
        .toolbar {
            Button(action: { showingAddGig.toggle() }) {
                Image(systemName: "plus")
            }
        }
        .sheet(isPresented: $showingAddGig) {
            AddGigView(bandId: bandId)
        }
        .onAppear {
            setupGigsListener()
        }
    }
    
    private func setupGigsListener() {
        db.collection("gigs")
            .whereField("bandId", isEqualTo: bandId)
            .whereField("date", isGreaterThan: Date())
            .order(by: "date")
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                gigs = documents.compactMap { try? $0.data(as: Gig.self) }
            }
    }
}
