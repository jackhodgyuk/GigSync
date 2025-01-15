import FirebaseFirestore
import Foundation

class SongService {
    static let shared = SongService()
    private let db = Firestore.firestore()
    
    func createLocalSong(title: String, duration: Int) -> Song {
        return Song(
            id: UUID().uuidString,
            title: title,
            duration: duration,
            order: 0
        )
    }
    
    func addSong(title: String, artist: String, duration: Int, key: String?, bandId: String) async throws -> String {
        let songData: [String: Any] = [
            "title": title,
            "artist": artist,
            "duration": duration,
            "key": key as Any,
            "bandId": bandId,
            "order": 0,
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        let docRef = try await db.collection("songs").addDocument(data: songData)
        return docRef.documentID
    }
    
    func batchSaveSongs(songs: [Song], bandId: String) async throws {
        let batch = db.batch()
        
        for song in songs {
            let docRef = db.collection("songs").document(song.id)
            let songData: [String: Any] = [
                "title": song.title,
                "duration": song.duration,
                "order": song.order,
                "bandId": bandId,
                "createdAt": FieldValue.serverTimestamp()
            ]
            batch.setData(songData, forDocument: docRef)
        }
        
        try await batch.commit()
    }
    
    func getSongs(bandId: String) async throws -> [Song] {
        let snapshot = try await db.collection("songs")
            .whereField("bandId", isEqualTo: bandId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
            
        return snapshot.documents.compactMap { try? $0.data(as: Song.self) }
    }
    
    func updateSong(_ song: Song) async throws {
        try await db.collection("songs").document(song.id).setData([
            "id": song.id,
            "title": song.title,
            "duration": song.duration,
            "order": song.order
        ], merge: true)
    }
    
    func deleteSong(_ songId: String) async throws {
        try await db.collection("songs").document(songId).delete()
    }
}
