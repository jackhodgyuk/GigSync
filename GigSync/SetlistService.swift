import FirebaseFirestore

class SetlistService {
    static let shared = SetlistService()
    private let db = Firestore.firestore()
    
    // MARK: - Create
    func createSetlist(name: String, songs: [Song], bandId: String) async throws -> String {
        let documentRef = db.collection("setlists").document()
        let documentId = documentRef.documentID
        
        let setlistData: [String: Any] = [
            "id": documentId,
            "name": name,
            "bandId": bandId,
            "songs": songs.map { [
                "id": $0.id,
                "title": $0.title,
                "duration": $0.duration,
                "order": $0.order
            ]},
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        try await documentRef.setData(setlistData)
        return documentId
    }
    
    // MARK: - Read
    func getSetlists(bandId: String) async throws -> [Setlist] {
        let snapshot = try await db.collection("setlists")
            .whereField("bandId", isEqualTo: bandId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        
        return try snapshot.documents.map { try $0.data(as: Setlist.self) }
    }
    
    // MARK: - Update
    func updateSongOrder(setlistId: String, songs: [Song]) async throws {
        let setlistRef = db.collection("setlists").document(setlistId)
        
        let songData = songs.enumerated().map { index, song in [
            "id": song.id,
            "title": song.title,
            "duration": song.duration,
            "order": index
        ]}
        
        try await setlistRef.updateData([
            "songs": songData
        ])
    }
    
    func addSong(to setlistId: String, song: Song) async throws {
        let setlistRef = db.collection("setlists").document(setlistId)
        
        let document = try await setlistRef.getDocument()
        var songs = (document.data()?["songs"] as? [[String: Any]]) ?? []
        
        let newSong: [String: Any] = [
            "id": song.id,
            "title": song.title,
            "duration": song.duration,
            "order": songs.count
        ]
        songs.append(newSong)
        
        try await setlistRef.updateData([
            "songs": songs
        ])
    }
    
    // MARK: - Delete
    func removeSongs(from setlistId: String, at offsets: IndexSet) async throws {
        let setlistRef = db.collection("setlists").document(setlistId)
        
        let document = try await setlistRef.getDocument()
        var songs = (document.data()?["songs"] as? [[String: Any]]) ?? []
        
        for index in offsets.sorted(by: >) {
            songs.remove(at: index)
        }
        
        songs = songs.enumerated().map { index, song in
            var updatedSong = song
            updatedSong["order"] = index
            return updatedSong
        }
        
        try await setlistRef.updateData([
            "songs": songs
        ])
    }
    
    func deleteSetlist(_ setlistId: String) async throws {
        try await db.collection("setlists").document(setlistId).delete()
    }
}

enum SetlistError: Error {
    case decodingError
}
