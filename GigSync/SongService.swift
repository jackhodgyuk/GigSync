//
//  SongService.swift
//  GigSync
//
//  Created by Jack Hodgy on 08/01/2025.
//


import FirebaseFirestore

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
            "createdAt": Date()
        ]
        
        let docRef = try await db.collection("songs").addDocument(data: songData)
        return docRef.documentID
    }
    
    func getSongs(bandId: String) async throws -> [Song] {
        let snapshot = try await db.collection("songs")
            .whereField("bandId", isEqualTo: bandId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
            
        return snapshot.documents.compactMap { try? $0.data(as: Song.self) }
    }
    
    func updateSong(_ song: Song) throws {
        try db.collection("songs").document(song.id).setData(from: song)
    }
    
    func deleteSong(_ songId: String) async throws {
        try await db.collection("songs").document(songId).delete()
    }
}
