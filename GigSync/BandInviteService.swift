import FirebaseFirestore
import CryptoKit

enum BandError: Error {
    case invalidInviteCode
    case userNotFound
    case alreadyMember
    case unauthorized
}

class BandInviteService {
    static let shared = BandInviteService()
    private let db = Firestore.firestore()
    
    func generateInviteCode() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let code = String((0..<6).map { _ in letters.randomElement()! })
        return code
    }
    
    func validateInviteCode(_ code: String) async throws -> String {
        let snapshot = try await db.collection("bands")
            .whereField("inviteCode", isEqualTo: code)
            .getDocuments()
        
        guard let bandDoc = snapshot.documents.first else {
            throw BandError.invalidInviteCode
        }
        
        return bandDoc.documentID
    }
    
    func refreshInviteCode(bandId: String) async throws -> String {
        let newCode = generateInviteCode()
        try await db.collection("bands").document(bandId).updateData([
            "inviteCode": newCode
        ])
        return newCode
    }
}
