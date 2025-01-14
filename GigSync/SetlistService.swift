import FirebaseFirestore

class SetlistService {
    static let shared = SetlistService()
    private let db = Firestore.firestore()
    
    // MARK: - Create
    func createSetlist(name: String, songs: [Song], bandId: String) async throws {
        let setlistData: [String: Any] = [
            "name": name,
            "bandId": bandId,
            "songs": songs.map { [
                "id": $0.id,
                "title": $0.title,
                "duration": $0.duration,
                "order": $0.order
            ]},
            "createdAt": Date()
        ]
        
        try await db.collection("setlists").document().setData(setlistData)
    }
    
    // MARK: - Read
    func getSetlists(bandId: String) async throws -> [Setlist] {
        let snapshot = try await db.collection("setlists")
            .whereField("bandId", isEqualTo: bandId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { try? $0.data(as: Setlist.self) }
    }
    
    // MARK: - Update
    func updateSongOrder(setlistId: String, songs: [Song]) async throws {
        try await db.collection("setlists").document(setlistId).updateData([
            "songs": songs.map { [
                "id": $0.id,
                "title": $0.title,
                "duration": $0.duration,
                "order": $0.order
            ]}
        ])
    }
    
    func addSong(to setlistId: String, song: Song) async throws {
        let setlistRef = db.collection("setlists").document(setlistId)
        
        // Get current document data
        let document = try await setlistRef.getDocument()
        guard let data = document.data() else { return }
        
        // Get current songs array
        var songs = (data["songs"] as? [[String: Any]]) ?? []
        
        // Create new song data
        let newSong: [String: Any] = [
            "id": song.id,
            "title": song.title,
            "duration": song.duration,
            "order": songs.count
        ]
        
        // Append new song
        songs.append(newSong)
        
        // Update document with new songs array
        try await setlistRef.updateData([
            "songs": songs
        ])
    }
    
    // MARK: - Delete
    func removeSongs(from setlistId: String, at offsets: IndexSet) async throws {
        let setlistRef = db.collection("setlists").document(setlistId)
        let snapshot = try await setlistRef.getDocument()
        guard var setlist = try? snapshot.data(as: Setlist.self) else { return }
        
        setlist.songs.remove(atOffsets: offsets)
        try await updateSongOrder(setlistId: setlistId, songs: setlist.songs)
    }
    
    func deleteSetlist(_ setlistId: String) async throws {
        try await db.collection("setlists").document(setlistId).delete()
    }
}
