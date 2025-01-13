import SwiftUI
import FirebaseFirestore

struct MemberGigDetailView: View {
    let gig: Gig
    @State private var attendance: AttendanceStatus = .pending
    @State private var listener: ListenerRegistration?
    
    private func loadInitialAttendance() {
        Task { @MainActor in
            if let gigId = gig.id {
                if let status = try? await AttendanceService.shared.getUserAttendanceStatus(gigId: gigId) {
                    attendance = status
                }
                
                // Store the listener reference
                listener = AttendanceService.shared.listenToUserAttendance(gigId: gigId) { newStatus in
                    Task { @MainActor in
                        if let newStatus = newStatus {
                            attendance = newStatus
                        }
                    }
                }
            }
        }
    }
    
    private func updateAttendance(_ status: AttendanceStatus) {
        Task {
            print("Updating attendance for gig: \(gig.id ?? "unknown")")
            print("New status: \(status)")
            try await AttendanceService.shared.updateAttendance(gigId: gig.id ?? "", status: status)
            print("Attendance updated successfully")
            await MainActor.run {
                attendance = status
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                GigHeroView(title: gig.title, date: gig.formattedDate)
                
                AttendanceToggle(status: Binding(
                    get: { attendance },
                    set: { newStatus in
                        attendance = newStatus
                        updateAttendance(newStatus)
                    }
                ))
                
                DetailCard(gig: gig)
                NotesCard(notes: gig.notes)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadInitialAttendance()
        }
        .onDisappear {
            // Remove the listener when view disappears
            listener?.remove()
        }
    }
}
