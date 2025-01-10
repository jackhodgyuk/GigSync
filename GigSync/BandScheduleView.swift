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
            isLoading = true
            if let bandId = band.id {
                let fetchedEvents = try await BandService.shared.getBandEvents(bandId: bandId)
                events = fetchedEvents.sorted { $0.date < $1.date }
            }
            isLoading = false
        }
    }
}
