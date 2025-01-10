import SwiftUI
import FirebaseFirestore

struct BandSettingsView: View {
    let band: Band
    @State private var showingDeleteConfirmation = false
    @State private var isLoading = false
    
    private let db = Firestore.firestore()
    
    var body: some View {
        Form {
            Section(header: Text("Band Information")) {
                HStack {
                    Text("Band Name")
                    Spacer()
                    Text(band.name)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Created")
                    Spacer()
                    Text(band.createdAt, style: .date)
                        .foregroundColor(.secondary)
                }
            }
            
            Section(header: Text("Invite Code")) {
                InviteCodeView(bandId: band.id, initialCode: band.id)  // Using band.id as the invite code
            }
            
            Section(header: Text("Danger Zone")) {
                Button(action: { showingDeleteConfirmation = true }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete Band")
                    }
                    .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Band Settings")
        .alert("Delete Band", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) { deleteBand() }
        } message: {
            Text("Are you sure you want to delete this band? This action cannot be undone.")
        }
    }
    
    private func deleteBand() {
        isLoading = true
        Task {
            try? await db.collection("bands").document(band.id).delete()
            isLoading = false
        }
    }
}
