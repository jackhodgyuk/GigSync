//
//  AddGigEventView.swift
//  GigSync
//
//  Created by Jack Hodgy on 08/01/2025.
//


import SwiftUI
import FirebaseAuth

struct AddGigEventView: View {
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var location = ""
    @State private var eventType: GigEvent.EventType = .gig
    @State private var date: Date
    @State private var notes = ""
    @State private var isLoading = false
    
    let bandId: String
    
    init(bandId: String, date: Date) {
        self.bandId = bandId
        _date = State(initialValue: date)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Event Details")) {
                    TextField("Title", text: $title)
                    TextField("Location", text: $location)
                    
                    Picker("Event Type", selection: $eventType) {
                        ForEach(GigEvent.EventType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    DatePicker("Date & Time", selection: $date)
                }
                
                Section(header: Text("Additional Information")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("New Event")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") { saveEvent() }
                    .disabled(title.isEmpty || isLoading)
            )
        }
    }
    
    private func saveEvent() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        
        Task {
            do {
                try await BandService.shared.createEvent(
                    title: title,
                    location: location,
                    type: eventType,
                    date: date,
                    notes: notes.isEmpty ? nil : notes,
                    bandId: bandId,
                    createdBy: userId
                )
                isLoading = false
                dismiss()
            } catch {
                isLoading = false
            }
        }
    }
}
