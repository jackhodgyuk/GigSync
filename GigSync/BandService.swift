import Foundation
import FirebaseFirestore
import FirebaseAuth

class BandService {
    static let shared = BandService()
    private let db = Firestore.firestore()
    private let appCreatorEmail = "jackhodgy@thetysms.co.uk"
    
    func getBandSetlists(bandId: String) async throws -> [Setlist] {
        let snapshot = try await db.collection("bands")
            .document(bandId)
            .collection("setlists")
            .getDocuments()
        
        return try snapshot.documents.map { document in
            try document.data(as: Setlist.self)
        }
    }
    
    func getBandMembers(bandId: String) async throws -> [User] {
        let bandDoc = try await db.collection("bands").document(bandId).getDocument()
        let band = try bandDoc.data(as: Band.self)
        
        return try await withThrowingTaskGroup(of: User?.self) { group in
            for userId in band.members.keys {
                group.addTask {
                    let userDoc = try? await self.db.collection("users").document(userId).getDocument()
                    return try? userDoc?.data(as: User.self)
                }
            }
            
            var members: [User] = []
            for try await member in group {
                if let member = member {
                    members.append(member)
                }
            }
            return members
        }
    }
    
    func getBandEvents(bandId: String) async throws -> [GigEvent] {
        let snapshot = try await db.collection("bands")
            .document(bandId)
            .collection("events")
            .getDocuments()
        
        return try snapshot.documents.map { document in
            try document.data(as: GigEvent.self)
        }
    }
    
    func removeMemberFromBand(userId: String, bandId: String) async throws {
        try await db.collection("bands")
            .document(bandId)
            .updateData([
                "members.\(userId)": FieldValue.delete()
            ])
    }
    
    func addMemberToBand(userId: String, bandId: String) async throws {
        try await db.collection("bands")
            .document(bandId)
            .updateData([
                "members.\(userId)": ["role": "member", "joinedAt": Timestamp()]
            ])
    }
    
    func joinBand(code: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        let snapshot = try await db.collection("bands")
            .whereField("joinCode", isEqualTo: code)
            .getDocuments()
        
        guard let bandDoc = snapshot.documents.first else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid invite code"])
        }
        
        let memberData: [String: Any] = [
            "members.\(userId)": [
                "role": "member",
                "joinedAt": Timestamp()
            ]
        ]
        
        try await db.collection("bands")
            .document(bandDoc.documentID)
            .updateData(memberData)
    }
    
    func updateBandInviteCode(bandId: String, newCode: String) async throws {
        guard let currentUser = Auth.auth().currentUser,
              currentUser.email == appCreatorEmail else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Only the app creator can modify invite codes"])
        }
        
        try await db.collection("bands")
            .document(bandId)
            .updateData(["joinCode": newCode])
    }
    
    func getUserBands(userId: String) async throws -> [Band] {
        print("Fetching bands for user: \(userId)")
        
        let snapshot = try await db.collection("bands")
            .whereField("members.\(userId)", isGreaterThan: [:])
            .getDocuments()
        
        let bands = try snapshot.documents.map { document in
            var band = try document.data(as: Band.self)
            band.id = document.documentID
            return band
        }
        
        print("Successfully loaded \(bands.count) bands with IDs: \(bands.map { $0.id ?? "none" })")
        return bands
    }
    
    func deleteEvent(_ eventId: String) async throws {
        let eventRef = db.collection("events").document(eventId)
        try await eventRef.delete()
    }
    
    func getEventSetlist(_ eventId: String) async throws -> String? {
        let eventDoc = try await db.collection("events").document(eventId).getDocument()
        let data = eventDoc.data()
        return data?["setlistId"] as? String
    }
    
    func assignSetlist(_ setlistId: String, to eventId: String) async throws {
        try await db.collection("events").document(eventId).updateData([
            "setlistId": setlistId
        ])
    }
    
    func createEvent(
        title: String,
        date: Date,
        location: String,
        type: GigEvent.EventType,
        notes: String?,
        bandId: String,
        createdBy: String
    ) async throws {
        let eventRef = db.collection("bands")
            .document(bandId)
            .collection("events")
            .document()
        
        let eventData: [String: Any] = [
            "id": eventRef.documentID,
            "title": title,
            "date": Timestamp(date: date),
            "location": location,
            "type": type.rawValue,
            "notes": notes as Any,
            "bandId": bandId,
            "createdBy": createdBy
        ]
        
        try await eventRef.setData(eventData)
    }
    
    func getBandStats(bandId: String, timeframe: TimeFrame) async throws -> BandStats {
        let eventsRef = db.collection("bands").document(bandId).collection("events")
        let setlistsRef = db.collection("bands").document(bandId).collection("setlists")
        
        async let eventsSnapshot = eventsRef.getDocuments()
        async let setlistsSnapshot = setlistsRef.getDocuments()
        
        let (events, setlists) = try await (eventsSnapshot, setlistsSnapshot)
        
        let totalGigs = events.documents.filter { ($0.data()["type"] as? String) == "gig" }.count
        let totalRevenue = events.documents.compactMap { ($0.data()["revenue"] as? Double) ?? 0.0 }.reduce(0, +)
        let totalSongs = setlists.documents.compactMap { ($0.data()["songs"] as? [String]) }.reduce(0) { $0 + $1.count }
        
        let bandDoc = try await db.collection("bands").document(bandId).getDocument()
        let band = try bandDoc.data(as: Band.self)
        
        return BandStats(
            totalGigs: totalGigs,
            totalRevenue: totalRevenue,
            activeMembers: band.memberCount,
            totalSongs: totalSongs,
            revenueChart: generateRevenueChart(from: events.documents)
        )
    }
    
    private func generateRevenueChart(from documents: [QueryDocumentSnapshot]) -> [ChartData] {
        let sortedDocs = documents.sorted {
            ($0.data()["date"] as? Timestamp)?.dateValue() ?? Date() <
                ($1.data()["date"] as? Timestamp)?.dateValue() ?? Date()
        }
        
        return sortedDocs.compactMap { doc -> ChartData? in
            guard let date = (doc.data()["date"] as? Timestamp)?.dateValue(),
                  let revenue = doc.data()["revenue"] as? Double else {
                return nil
            }
            return ChartData(date: date, amount: revenue)
        }
    }
    
    func createBandWithUser(name: String, genre: String) async throws -> Band {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        let bandRef = db.collection("bands").document()
        let joinCode = String((0..<6).map { _ in "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".randomElement()! })
        
        let band = Band(
            id: bandRef.documentID,
            name: name,
            members: [userId: BandMemberInfo(role: .admin, joinedAt: Date())],
            createdAt: Date(),
            imageUrl: nil,
            description: nil,
            genre: genre,
            joinCode: joinCode
        )
        
        let bandData = try Firestore.Encoder().encode(band)
        try await bandRef.setData(bandData)
        return band
    }
    func diagnoseBandAccess(userId: String) async {
        print("Running band access diagnosis for user: \(userId)")
        
        do {
            // Check direct band access
            let bandDoc = try await db.collection("bands")
                .document("aOtnxHL6EF07FUYoRTR3")
                .getDocument()
            
            if let data = bandDoc.data() {
                print("Band exists with data:")
                if let members = data["members"] as? [String: Any] {
                    print("All members: \(members)")
                    print("Current user membership: \(members[Auth.auth().currentUser?.uid ?? ""] ?? "not found")")
                }
            }
            
            // Check query results
            let snapshot = try await db.collection("bands")
                .whereField("members.\(Auth.auth().currentUser?.uid ?? "")", isGreaterThan: [:])
                .getDocuments()
            
            print("Query found \(snapshot.documents.count) bands")
        } catch {
            print("Diagnosis error: \(error)")
        }
    }
}
