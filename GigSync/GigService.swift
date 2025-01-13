import FirebaseFirestore
import FirebaseAuth

class GigService {
    static let shared = GigService()
    private let db = Firestore.firestore()
    
    func createGig(title: String, venue: String, date: Date, notes: String, setlistId: String?, bandId: String) async throws {
        let gigData: [String: Any] = [
            "title": title,
            "venue": venue,
            "date": date,
            "notes": notes,
            "setlistId": setlistId ?? "",
            "bandId": bandId,
            "createdAt": Date(),
            "visibility": ["admin", "manager", "member"],
            "status": "active",
            "id": UUID().uuidString,
            "lastModified": Date(),
            "createdBy": Auth.auth().currentUser?.uid ?? "",
            "attendees": [:]
        ]
        
        let docRef = db.collection("gigs").document()
        try await docRef.setData(gigData)
        print("Created gig with ID: \(docRef.documentID)")
    }
    
    func fetchGigs(for bandId: String) async throws -> [Gig] {
        print("Fetching gigs for band: \(bandId)")
        let snapshot = try await db.collection("gigs")
            .whereField("bandId", isEqualTo: bandId)
            .whereField("status", isEqualTo: "active")
            .order(by: "date")
            .getDocuments()
        
        let gigs = snapshot.documents.compactMap { document in
            try? document.data(as: Gig.self)
        }
        print("Fetched \(gigs.count) gigs for band \(bandId)")
        return gigs
    }
    
    func listenToGigs(bandId: String, completion: @escaping ([Gig]) -> Void) -> ListenerRegistration {
        print("Setting up real-time gigs listener for band: \(bandId)")
        return db.collection("gigs")
            .whereField("bandId", isEqualTo: bandId)
            .whereField("status", isEqualTo: "active")
            .order(by: "date")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error in gigs listener: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No gig documents found for band \(bandId)")
                    completion([])
                    return
                }
                
                let gigs = documents.compactMap { document in
                    try? document.data(as: Gig.self)
                }
                print("Real-time update: Found \(gigs.count) gigs for band \(bandId)")
                completion(gigs)
            }
    }
    
    func updateAttendance(gigId: String, isAttending: Bool) async throws {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let docRef = db.collection("gigs").document(gigId)
        try await docRef.updateData([
            "attendees.\(userId)": [
                "isAttending": isAttending,
                "updatedAt": Date()
            ]
        ])
    }
    
    func getAttendanceStatus(gigId: String) async throws -> Bool? {
        guard let userId = Auth.auth().currentUser?.uid else { return nil }
        let doc = try await db.collection("gigs").document(gigId).getDocument()
        
        let data = doc.data()
        let attendees = data?["attendees"] as? [String: [String: Any]]
        let userStatus = attendees?[userId] as? [String: Any]
        return userStatus?["isAttending"] as? Bool
    }
}
