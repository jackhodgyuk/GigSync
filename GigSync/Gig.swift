import Foundation
import FirebaseFirestore

struct Gig: Identifiable, Codable {
    @DocumentID var id: String?
    let title: String
    let date: Date
    let venue: String
    let notes: String
    let bandId: String
    let setlistId: String?
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, date, venue, notes, bandId, setlistId
    }
}
