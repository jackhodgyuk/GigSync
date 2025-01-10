import Foundation
import FirebaseFirestore
import FirebaseAuth

class BandService {
    static let shared = BandService()
    private let db = Firestore.firestore()
    
    func addMemberToBand(userId: String, bandId: String) async throws {
        let bandRef = db.collection("bands").document(bandId)
        let userRef = db.collection("users").document(userId)
        
        _ = try await db.runTransaction { (transaction, _) -> Any? in
            transaction.updateData([
                "members.\(userId)": [
                    "role": "member",
                    "joinedAt": Date()
                ]
            ], forDocument: bandRef)
            
            transaction.updateData([
                "bandIds": FieldValue.arrayUnion([bandId])
            ], forDocument: userRef)
            
            return nil
        }
    }
    
    func removeMemberFromBand(userId: String, bandId: String) async throws {
        let bandRef = db.collection("bands").document(bandId)
        let userRef = db.collection("users").document(userId)
        
        _ = try await db.runTransaction { (transaction, _) -> Any? in
            transaction.updateData([
                "members.\(userId)": FieldValue.delete()
            ], forDocument: bandRef)
            
            transaction.updateData([
                "bandIds": FieldValue.arrayRemove([bandId])
            ], forDocument: userRef)
            
            return nil
        }
    }
    
    func getUserBands(userId: String) async throws -> [Band] {
        let userDoc = try await db.collection("users").document(userId).getDocument()
        guard let bandIds = userDoc.data()?["bandIds"] as? [String] else { return [] }
        
        let bands = try await withThrowingTaskGroup(of: Band?.self) { group in
            for bandId in bandIds {
                group.addTask {
                    let bandDoc = try? await self.db.collection("bands").document(bandId).getDocument()
                    return try? bandDoc?.data(as: Band.self)
                }
            }
            
            var results: [Band] = []
            for try await band in group {
                if let band = band {
                    results.append(band)
                }
            }
            return results
        }
        
        return bands
    }
    
    func getBandStats(bandId: String, timeframe: TimeFrame) async throws -> BandStats {
        let startDate = timeframe.startDate
        
        async let gigsQuery = db.collection("gigs")
            .whereField("bandId", isEqualTo: bandId)
            .whereField("date", isGreaterThan: startDate)
            .getDocuments()
        
        async let financesQuery = db.collection("finances")
            .whereField("bandId", isEqualTo: bandId)
            .whereField("date", isGreaterThan: startDate)
            .getDocuments()
        
        async let setlistsQuery = db.collection("setlists")
            .whereField("bandId", isEqualTo: bandId)
            .getDocuments()
        
        let (gigs, finances, setlists) = try await (gigsQuery, financesQuery, setlistsQuery)
        let bandDoc = try await db.collection("bands").document(bandId).getDocument()
        let band = try bandDoc.data(as: Band.self)
        
        return BandStats(
            totalGigs: gigs.documents.count,
            totalRevenue: calculateRevenue(from: finances.documents),
            activeMembers: band.memberCount,
            totalSongs: calculateTotalSongs(from: setlists.documents),
            revenueChart: createRevenueChart(from: finances.documents)
        )
    }
    
    func createEvent(title: String, location: String, type: GigEvent.EventType, date: Date, notes: String?, bandId: String, createdBy: String) async throws {
        let eventData: [String: Any] = [
            "title": title,
            "location": location,
            "type": type.rawValue,
            "date": date,
            "notes": notes as Any,
            "bandId": bandId,
            "createdBy": createdBy,
            "createdAt": Date()
        ]
        
        try await db.collection("events").document().setData(eventData)
    }
    
    func getBandEvents(bandId: String) async throws -> [GigEvent] {
        let snapshot = try await db.collection("events")
            .whereField("bandId", isEqualTo: bandId)
            .order(by: "date")
            .getDocuments()
        
        return snapshot.documents.compactMap { try? $0.data(as: GigEvent.self) }
    }
    
    func deleteEvent(_ eventId: String) async throws {
        try await db.collection("events").document(eventId).delete()
    }
    
    func updateEvent(_ event: GigEvent) throws {
        try db.collection("events").document(event.id).setData(from: event)
    }
    
    func getEventSetlist(_ eventId: String) async throws -> String? {
        let snapshot = try await db.collection("events")
            .document(eventId)
            .getDocument()
        
        return snapshot.data()?["setlistId"] as? String
    }
    
    func assignSetlist(_ setlistId: String, to eventId: String) async throws {
        try await db.collection("events")
            .document(eventId)
            .updateData(["setlistId": setlistId])
    }
    
    func getGigSetlist(gigId: String) async throws -> Setlist? {
        let gigDoc = try await db.collection("events").document(gigId).getDocument()
        guard let setlistId = gigDoc.data()?["setlistId"] as? String else { return nil }
        
        let setlistDoc = try await db.collection("setlists").document(setlistId).getDocument()
        return try? setlistDoc.data(as: Setlist.self)
    }
    
    func assignSetlistToGig(setlistId: String, gigId: String) async throws {
        try await db.collection("events").document(gigId).updateData([
            "setlistId": setlistId,
            "updatedAt": Date()
        ])
    }
    
    func removeSetlistFromGig(gigId: String) async throws {
        try await db.collection("events").document(gigId).updateData([
            "setlistId": FieldValue.delete(),
            "updatedAt": Date()
        ])
    }
    
    private func calculateRevenue(from documents: [QueryDocumentSnapshot]) -> Double {
        documents
            .compactMap { try? $0.data(as: Finance.self) }
            .filter { $0.category == .income }
            .reduce(0) { $0 + $1.amount }
    }
    
    private func calculateTotalSongs(from documents: [QueryDocumentSnapshot]) -> Int {
        documents
            .compactMap { try? $0.data(as: Setlist.self) }
            .reduce(0) { $0 + $1.songs.count }
    }
    
    private func createRevenueChart(from documents: [QueryDocumentSnapshot]) -> [ChartData] {
        let finances = documents.compactMap { try? $0.data(as: Finance.self) }
        let grouped = Dictionary(grouping: finances) { finance in
            Calendar.current.startOfDay(for: finance.date)
        }
        
        return grouped.map { date, finances in
            let dailyTotal = finances.reduce(0) { $0 + $1.amount }
            return ChartData(date: date, amount: dailyTotal)
        }.sorted { $0.date < $1.date }
    }
    
    func createBand(name: String, genre: String) async throws -> String {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw BandError.userNotAuthenticated
        }
        
        let joinCode = UUID().uuidString.prefix(6).uppercased()
        let bandData: [String: Any] = [
            "name": name,
            "genre": genre,
            "createdAt": Date(),
            "joinCode": joinCode,
            "members": [
                userId: [
                    "role": "admin",
                    "joinedAt": Date()
                ]
            ]
        ]
        
        let docRef = try await db.collection("bands").addDocument(data: bandData)
        
        // Update user's bandIds
        try await db.collection("users").document(userId).updateData([
            "bandIds": FieldValue.arrayUnion([docRef.documentID])
        ])
        
        return docRef.documentID
    }
    
    enum BandError: Error {
        case invalidInviteCode
        case bandNotFound
        case userAlreadyMember
        case networkError
        case userNotAuthenticated
        
        var localizedDescription: String {
            switch self {
            case .invalidInviteCode: return "Invalid invite code"
            case .bandNotFound: return "Band not found"
            case .userAlreadyMember: return "You're already a member of this band"
            case .networkError: return "Network connection error"
            case .userNotAuthenticated: return "Please sign in to join a band"
            }
        }
    }
    
    func joinBand(code: String) async throws {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw BandError.userNotAuthenticated
        }
        
        let bandQuery = try await db.collection("bands")
            .whereField("joinCode", isEqualTo: code)
            .getDocuments()
        
        guard let bandDoc = bandQuery.documents.first else {
            throw BandError.invalidInviteCode
        }
        
        let bandId = bandDoc.documentID
        
        // Check if user is already a member
        let memberDoc = try await db.collection("bands")
            .document(bandId)
            .collection("members")
            .document(currentUserId)
            .getDocument()
        
        if memberDoc.exists {
            throw BandError.userAlreadyMember
        }
        
        // Add member to band
        try await addMemberToBand(userId: currentUserId, bandId: bandId)
    }
    // Add these new methods to your existing BandService class
    
    func createBandWithUser(name: String, genre: String) async throws -> Band {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw BandError.userNotAuthenticated
        }
        
        let db = Firestore.firestore()
        let batch = db.batch()
        
        // Create new band document
        let bandRef = db.collection("bands").document()
        let joinCode = UUID().uuidString.prefix(6).uppercased()
        
        let memberInfo = MemberInfo(role: "admin", joinedAt: Date())
        let band = Band(
            id: bandRef.documentID,
            name: name,
            members: [userId: memberInfo],
            createdAt: Date(),
            imageUrl: nil,
            description: nil,
            genre: genre,
            joinCode: joinCode
        )
        
        try batch.setData(from: band, forDocument: bandRef)
        
        // Update user's bandIds
        let userRef = db.collection("users").document(userId)
        batch.updateData([
            "bandIds": FieldValue.arrayUnion([bandRef.documentID])
        ], forDocument: userRef)
        
        try await batch.commit()
        return band
    }
    
    func listenToBandUpdates(bandId: String, completion: @escaping (Band?) -> Void) -> ListenerRegistration {
        return db.collection("bands").document(bandId)
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    completion(nil)
                    return
                }
                let band = try? document.data(as: Band.self)
                completion(band)
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
}
