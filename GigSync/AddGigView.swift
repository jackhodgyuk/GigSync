import SwiftUI
import FirebaseFirestore

struct AddGigView: View {
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var venue = ""
    @State private var date = Date()
    @State private var notes = ""
    @State private var selectedSetlist: String?
    @State private var setlists: [Setlist] = []
    @State private var isLoading = false
    let bandId: String
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Gig Details")) {
                    TextField("Gig Title", text: $title)
                    TextField("Venue", text: $venue)
                    DatePicker("Date & Time", selection: $date)
                }
                
                Section(header: Text("Setlist")) {
                    Picker("Select Setlist", selection: $selectedSetlist) {
                        Text("No Setlist").tag(nil as String?)
                        ForEach(setlists) { setlist in
                            Text(setlist.name).tag(setlist.id as String?)
                        }
                    }
                }
                
                Section(header: Text("Additional Notes")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Add New Gig")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") { saveGig() }
                    .disabled(isLoading || title.isEmpty || venue.isEmpty)
            )
            .overlay {
                if isLoading {
                    ProgressView()
                }
            }
        }
    }
    
    private func saveGig() {
        isLoading = true
        Task {
            do {
                try await GigService.shared.createGig(
                    title: title,
                    venue: venue,
                    date: date,
                    notes: notes,
                    setlistId: selectedSetlist,
                    bandId: bandId
                )
                isLoading = false
                dismiss()
            } catch {
                isLoading = false
                // Handle error
            }
        }
    }
}
