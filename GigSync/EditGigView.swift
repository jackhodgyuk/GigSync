import SwiftUI
import FirebaseFirestore

struct EditGigView: View {
    @Environment(\.dismiss) var dismiss
    let gig: Gig
    @State private var title: String
    @State private var venue: String
    @State private var date: Date
    @State private var notes: String
    @State private var setlistId: String
    
    private let db = Firestore.firestore()
    
    init(gig: Gig) {
        self.gig = gig
        _title = State(initialValue: gig.title)
        _venue = State(initialValue: gig.venue)
        _date = State(initialValue: gig.date)
        _notes = State(initialValue: gig.notes)
        _setlistId = State(initialValue: gig.setlistId ?? "")
    }
    
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Title", text: $title)
                TextField("Venue", text: $venue)
                DatePicker("Date", selection: $date)
                TextField("Notes", text: $notes, axis: .vertical)
                    .lineLimit(5...)
            }
            .navigationTitle("Edit Gig")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") { saveChanges() }
            )
        }
    }
    
    private func saveChanges() {
        let updatedGig = Gig(
            id: gig.id,
            title: title,
            date: date,
            venue: venue,
            notes: notes,
            bandId: gig.bandId,
            setlistId: setlistId.isEmpty ? nil : setlistId
        )
        
        Task {
            let data = try JSONEncoder().encode(updatedGig)
            let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
            try await db.collection("gigs").document(gig.id).setData(dict)
            dismiss()
        }
    }
}
