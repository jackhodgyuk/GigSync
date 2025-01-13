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
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(gigs) { gig in
                            NavigationLink(destination: GigDetailView(gig: gig, isAdmin: true)) {
                                GigCard(gig: gig) {
                                    deleteGig(gig)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Upcoming Gigs")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddGig.toggle() }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(.accentColor)
                    }
                }
            }
            .sheet(isPresented: $showingAddGig) {
                AddGigView(bandId: bandId)
            }
        }
        .onAppear { setupGigsListener() }
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
                guard let gigId = gig.id else { return }
                try await db.collection("gigs").document(gigId).delete()
            } catch {
                print("Error deleting gig: \(error.localizedDescription)")
            }
        }
    }
}

struct GigCard: View {
    let gig: Gig
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text(gig.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(gig.venue)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Menu {
                    Button(role: .destructive, action: onDelete) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.accentColor)
                Text(gig.formattedDate)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 2)
    }
}
