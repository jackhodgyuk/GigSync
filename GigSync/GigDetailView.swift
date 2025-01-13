import SwiftUI
import FirebaseFirestore

struct GigDetailView: View {
    let gig: Gig
    let isAdmin: Bool
    @State private var showingEditSheet = false
    @State private var showingSetlistPicker = false
    @State private var attendance: AttendanceStatus = .pending
    @State private var listener: ListenerRegistration?
    @State private var userNames: [String: String] = [:]
    
    private func loadInitialAttendance() {
        Task { @MainActor in
            if let gigId = gig.id {
                if let status = try? await AttendanceService.shared.getUserAttendanceStatus(gigId: gigId) {
                    attendance = status
                }
                
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
    
    private func fetchUserNames(for userIds: [String]) {
        Task {
            let db = Firestore.firestore()
            for userId in userIds {
                if userNames[userId] == nil {
                    if let snapshot = try? await db.collection("users").document(userId).getDocument(),
                       let name = snapshot.data()?["name"] as? String {
                        await MainActor.run {
                            userNames[userId] = name
                        }
                    }
                }
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
                // In the body's VStack, replace the AttendanceList line with:
                AttendanceList(gigId: gig.id ?? "", bandId: gig.bandId)
                NotesCard(notes: gig.notes)
                SetlistCard(showPicker: $showingSetlistPicker)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if isAdmin {
                    Button("Edit") { showingEditSheet.toggle() }
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditGigView(gig: gig)
        }
        .sheet(isPresented: $showingSetlistPicker) {
            if let gigId = gig.id {
                SetlistPickerView(eventId: gigId, bandId: gig.bandId)
            }
        }
        .onAppear {
            loadInitialAttendance()
        }
        .onDisappear {
            listener?.remove()
        }
    }
    
    // Add this nested view inside GigDetailView
    private struct AttendanceList: View {
        let gigId: String
        let bandId: String
        @State private var attendances: [Attendance] = []
        @State private var userNames: [String: String] = [:]
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text("Who's Coming")
                    .font(.headline)
                
                ForEach(attendances.sorted { $0.timestamp > $1.timestamp }, id: \.userId) { attendance in
                    if attendance.status != .pending {  // Only show non-pending statuses
                        HStack {
                            Text(userNames[attendance.userId] ?? "Loading...")
                            Spacer()
                            Text(attendance.status.rawValue)
                                .foregroundColor(attendance.status.color)
                        }
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(15)
            .shadow(radius: 2)
            .onAppear {
                listenToAttendances()
            }
        }
        
        private func listenToAttendances() {
            AttendanceService.shared.listenToAttendance(gigId: gigId) { newAttendances in
                Task { @MainActor in
                    self.attendances = newAttendances
                    fetchUserNames(for: newAttendances.map { $0.userId })
                }
            }
        }
        
        private func fetchUserNames(for userIds: [String]) {
            let db = Firestore.firestore()
            for userId in userIds {
                if userNames[userId] == nil {
                    db.collection("users").document(userId).getDocument { snapshot, _ in
                        if let name = snapshot?.data()?["name"] as? String {
                            DispatchQueue.main.async {
                                userNames[userId] = name
                            }
                        }
                    }
                }
            }
        }
    }
}
