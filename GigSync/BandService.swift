import Foundation
import FirebaseFirestore
import FirebaseAuth

class BandService {
    static let shared = BandService()
    private let db = Firestore.firestore()
    
    // [Previous code remains exactly the same until the getBandSetlists function]
    
    func getBandSetlists(bandId: String) async throws -> [Setlist] {
        let snapshot = try await db.collection("bands")
            .document(bandId)
            .collection("setlists")
            .getDocuments()
        
        return try snapshot.documents.map { document in
            try document.data(as: Setlist.self)
        }
    }
    
    // [All the code between getBandSetlists and the end remains exactly the same]
    
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
