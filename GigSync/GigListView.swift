import SwiftUI
import FirebaseFirestore

struct GigListView: View {
    let bandId: String
    let isAdmin: Bool
    @State private var gigs: [Gig] = []
    @State private var showingAddGig = false
    private let db = Firestore.firestore()
    
    var body: some View {
        List {
            ForEach(gigs) { gig in
                NavigationLink(destination:
                    Group {
                        if isAdmin {
                            GigDetailView(gig: gig, isAdmin: true)
                        } else {
                            MemberGigDetailView(gig: gig)
                        }
                    }
                ) {
                    GigRowView(gig: gig)
                }
            }
        }
        .navigationTitle("Upcoming Gigs")
        .toolbar {
            if isAdmin {
                Button(action: { showingAddGig.toggle() }) {
                    Image(systemName: "plus")
                }
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
        print("Setting up gigs listener for bandId: \(bandId)")
        db.collection("gigs")
            .whereField("bandId", isEqualTo: bandId)
            .order(by: "date")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching gigs: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No documents found")
                    return
                }
                print("Found \(documents.count) gig documents")
                
                gigs = documents.compactMap { document in
                    do {
                        let gig = try document.data(as: Gig.self)
                        print("Successfully decoded gig: \(gig.id ?? "unknown")")
                        return gig
                    } catch {
                        print("Error decoding gig: \(error)")
                        return nil
                    }
                }
                print("Final gigs array count: \(gigs.count)")
            }
    }
}
