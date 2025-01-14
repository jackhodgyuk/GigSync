import FirebaseFirestore
import Foundation

// Reference the model from Models directory
typealias SongModel = GigSync.Song

class SongService {
    static let shared = SongService()
    private let db = Firestore.firestore()
    
    func addSong(title: String, artist: String, duration: Int, key: String?, bandId: String) async throws -> String {
        let songData: [String: Any] = [
            "title": title,
            "artist": artist,
            "duration": duration,
            "key": key as Any,
            "bandId": bandId,
            "order": 0,
            "createdAt": Date()
        ]
        
        let docRef = try await db.collection("songs").addDocument(data: songData)
        return docRef.documentID
    }
    
    func getSongs(bandId: String) async throws -> [SongModel] {
        let snapshot = try await db.collection("songs")
            .whereField("bandId", isEqualTo: bandId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
            
        return snapshot.documents.compactMap { try? $0.data(as: SongModel.self) }
    }
    
    func updateSong(_ song: SongModel) async throws {
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
