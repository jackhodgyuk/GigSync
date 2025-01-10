//
//  EditGigEventView.swift
//  GigSync
//
//  Created by Jack Hodgy on 08/01/2025.
//


import SwiftUI
import FirebaseFirestore

struct EditGigEventView: View {
    @Environment(\.dismiss) var dismiss
    @State private var title: String
    @State private var location: String
    @State private var eventType: GigEvent.EventType
    @State private var date: Date
    @State private var notes: String
    @State private var isLoading = false
    
    let event: GigEvent
    
    init(event: GigEvent) {
        self.event = event
        _title = State(initialValue: event.title)
        _location = State(initialValue: event.location)
        _eventType = State(initialValue: event.type)
        _date = State(initialValue: event.date)
        _notes = State(initialValue: event.notes ?? "")
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
            .navigationTitle("Edit Event")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") { saveChanges() }
                    .disabled(title.isEmpty || isLoading)
            )
        }
    }
    
    private func saveChanges() {
        isLoading = true
        
        let updatedEvent = GigEvent(
            id: event.id,
            title: title,
            date: date,
            location: location,
            type: eventType,
            notes: notes.isEmpty ? nil : notes,
            bandId: event.bandId,
            createdBy: event.createdBy
        )
        
        let db = Firestore.firestore()
        Task {
            do {
                let data = try JSONEncoder().encode(updatedEvent)
                let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
                try await db.collection("events").document(event.id).setData(dict)
                await MainActor.run {
                    isLoading = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
}
