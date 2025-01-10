import SwiftUI
import FirebaseFirestore

struct GigManagementView: View {
    @State private var gigs: [Gig] = []
    @State private var showingAddGig = false
    @State private var selectedGig: Gig?
    let bandId: String
    
    private let db = Firestore.firestore()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(gigs) { gig in
                    NavigationLink(destination: GigDetailView(gig: gig)) {
                        GigRowView(gig: gig)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    deleteGig(gig)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
            }
            .navigationTitle("Gigs")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddGig.toggle() }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddGig) {
                AddGigView(bandId: bandId)
            }
        }
        .onAppear {
            setupGigsListener()
        }
    }
    
    private func setupGigsListener() {
        db.collection("gigs")
            .whereField("bandId", isEqualTo: bandId)
            .order(by: "date")
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                gigs = documents.compactMap { try? $0.data(as: Gig.self) }
            }
    }
    
    private func deleteGig(_ gig: Gig) {
        Task {
            do {
                try await db.collection("gigs").document(gig.id).delete()
            } catch {
                print("Error deleting gig: \(error.localizedDescription)")
            }
        }
    }
}
