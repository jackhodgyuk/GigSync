import SwiftUI

struct GigEventDetailView: View {
    @State private var event: GigEvent
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    init(event: GigEvent) {
        _event = State(initialValue: event)
    }
    
    var body: some View {
        List {
            Section {
                HStack {
                    EventTypeIcon(type: event.type)
                    Text(event.type.rawValue)
                }
                
                HStack {
                    Image(systemName: "calendar")
                    Text(event.date, style: .date)
                }
                
                HStack {
                    Image(systemName: "clock")
                    Text(event.date, style: .time)
                }
                
                if !event.location.isEmpty {
                    HStack {
                        Image(systemName: "mappin")
                        Text(event.location)
                    }
                }
            }
            
            if let notes = event.notes, !notes.isEmpty {
                Section("Notes") {
                    Text(notes)
                }
            }
            
            if event.type == .gig {
                Section("Setlist") {
                    NavigationLink("View Setlist") {
                        SetlistPickerView(eventId: event.id, bandId: event.bandId)
                    }
                }
            }
        }
        .navigationTitle(event.title)
        .toolbar {
            Menu {
                Button("Edit") { showingEditSheet = true }
                Button("Delete", role: .destructive) { showingDeleteAlert = true }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditGigEventView(event: event)
        }
        .alert("Delete Event", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) { deleteEvent() }
        } message: {
            Text("Are you sure you want to delete this event?")
        }
    }
    
    private func deleteEvent() {
        Task {
            try? await BandService.shared.deleteEvent(event.id)
        }
    }
}
