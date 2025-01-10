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
            "createdAt": Date()
        ]
        
        let docRef = db.collection("gigs").document()
        try await docRef.setData(gigData)
    }
    
    func fetchGigs(for bandId: String) async throws -> [Gig] {
        let snapshot = try await db.collection("gigs")
            .whereField("bandId", isEqualTo: bandId)
            .order(by: "date")
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: Gig.self)
        }
    }
    
    func listenToGigs(bandId: String, completion: @escaping ([Gig]) -> Void) -> ListenerRegistration {
        return db.collection("gigs")
            .whereField("bandId", isEqualTo: bandId)
            .order(by: "date")
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                let gigs = documents.compactMap { try? $0.data(as: Gig.self) }
                completion(gigs)
            }
    }
}
