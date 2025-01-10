import SwiftUI
import FirebaseFirestore

struct GigDetailView: View {
    let gig: Gig
    @State private var showingEditSheet = false
    @State private var showingSetlistPicker = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Details Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Details")
                        .font(.headline)
                    
                    HStack {
                        Image(systemName: "calendar")
                        Text(gig.formattedDate)
                    }
                    
                    HStack {
                        Image(systemName: "mappin.circle")
                        Text(gig.venue)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .shadow(radius: 1)
                
                // Notes Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Notes")
                        .font(.headline)
                    Text(gig.notes)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .shadow(radius: 1)
                
                // Setlist Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Setlist")
                        .font(.headline)
                    Button("Manage Setlist") {
                        showingSetlistPicker = true
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .shadow(radius: 1)
            }
            .padding()
        }
        .navigationTitle(gig.title)
        .toolbar {
            Button("Edit") {
                showingEditSheet = true
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditGigView(gig: gig)
        }
        .sheet(isPresented: $showingSetlistPicker) {
            SetlistPickerView(eventId: gig.id, bandId: gig.bandId)
        }
    }
}
