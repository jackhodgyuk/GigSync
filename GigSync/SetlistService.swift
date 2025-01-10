//
//  SetlistService.swift
//  GigSync
//
//  Created by Jack Hodgy on 08/01/2025.
//


import FirebaseFirestore

class SetlistService {
    static let shared = SetlistService()
    private let db = Firestore.firestore()
    
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
        try await setlistRef.updateData([
            "songs": FieldValue.arrayUnion([[
                "id": song.id,
                "title": song.title,
                "duration": song.duration,
                "order": song.order
            ]])
        ])
    }
    
    func removeSongs(from setlistId: String, at offsets: IndexSet) async throws {
        let setlistRef = db.collection("setlists").document(setlistId)
        let snapshot = try await setlistRef.getDocument()
        guard var setlist = try? snapshot.data(as: Setlist.self) else { return }
        
        setlist.songs.remove(atOffsets: offsets)
        try await updateSongOrder(setlistId: setlistId, songs: setlist.songs)
    }
    
    func getSetlists(bandId: String) async throws -> [Setlist] {
        let snapshot = try await db.collection("setlists")
            .whereField("bandId", isEqualTo: bandId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { try? $0.data(as: Setlist.self) }
    }
    
}
