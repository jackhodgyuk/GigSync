//
//  BandScheduleView.swift
//  GigSync
//
//  Created by Jack Hodgy on 08/01/2025.
//


import SwiftUI

struct BandScheduleView: View {
    let band: Band
    @State private var events: [GigEvent] = []
    @State private var isLoading = false
    
    var body: some View {
        List {
            ForEach(events) { event in
                VStack(alignment: .leading) {
                    Text(event.title)
                        .font(.headline)
                    Text(event.location)
                        .font(.subheadline)
                    Text(event.date.formatted())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Schedule")
        .onAppear {
            loadEvents()
        }
    }
    
    private func loadEvents() {
        Task {
            events = try await BandService.shared.getBandEvents(bandId: band.id)
        }
    }
}
