//
//  GigService.swift
//  GigSync
//
//  Created by Jack Hodgy on 08/01/2025.
//


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
        
        try await db.collection("gigs").document().setData(gigData)
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
}
