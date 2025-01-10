import FirebaseFirestore

class UserService {
    static let shared = UserService()
    private let db = Firestore.firestore()
    
    func getUser(userId: String) async throws -> User {
        let document = try await db.collection("users").document(userId).getDocument()
        return try document.data(as: User.self)
    }
    
    func searchUsers(query: String) async throws -> [User] {
        let snapshot = try await db.collection("users")
            .whereField("name", isGreaterThanOrEqualTo: query)
            .whereField("name", isLessThan: query + "z")
            .limit(to: 10)
            .getDocuments()
        
        return snapshot.documents.compactMap { try? $0.data(as: User.self) }
    }
    
    func updateUser(_ user: User) throws {
        guard let userId = user.id else { return }
        try db.collection("users").document(userId).setData(from: user)
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
}
