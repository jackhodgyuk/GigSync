//
//  BandCalendarView.swift
//  GigSync
//
//  Created by Jack Hodgy on 08/01/2025.
//


import SwiftUI

struct BandCalendarView: View {
    @State private var selectedDate = Date()
    @State private var events: [GigEvent] = []
    @State private var showingAddEvent = false
    let bandId: String
    
    var body: some View {
        VStack {
            DatePicker(
                "Select Date",
                selection: $selectedDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .padding()
            
            List {
                ForEach(eventsForSelectedDate) { event in
                    GigEventRow(event: event)
                }
            }
        }
        .navigationTitle("Band Calendar")
        .toolbar {
            Button(action: { showingAddEvent.toggle() }) {
                Image(systemName: "plus")
            }
        }
        .sheet(isPresented: $showingAddEvent) {
            AddGigEventView(bandId: bandId, date: selectedDate)
        }
        .onAppear {
            loadEvents()
        }
    }
    
    private var eventsForSelectedDate: [GigEvent] {
        events.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }
    
    private func loadEvents() {
        Task {
            events = try await BandService.shared.getBandEvents(bandId: bandId)
        }
    }
}
