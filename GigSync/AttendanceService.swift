import Foundation
import FirebaseFirestore
import FirebaseAuth

class AttendanceService {
    static let shared = AttendanceService()
    private let db = Firestore.firestore()
    
    // MARK: - Update Methods
    func updateAttendance(gigId: String, status: AttendanceStatus) async throws {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        print("Writing attendance - GigID: \(gigId), Status: \(status), UserID: \(userId)")
        
        let attendanceData: [String: Any] = [
            "userId": userId,
            "status": status.rawValue,
            "timestamp": Timestamp(date: Date())
        ]
        
        try await db.collection("gigs")
            .document(gigId)
            .collection("attendance")
            .document(userId)
            .setData(attendanceData)
        
        print("Attendance write completed with data: \(attendanceData)")
    }
    
    // MARK: - Fetch Methods
    func getAttendanceList(gigId: String) async throws -> [Attendance] {
        let snapshot = try await db.collection("gigs")
            .document(gigId)
            .collection("attendance")
            .getDocuments()
        
        return try snapshot.documents.map { try $0.data(as: Attendance.self) }
    }
    
    func getUserAttendanceStatus(gigId: String) async throws -> AttendanceStatus? {
        guard let userId = Auth.auth().currentUser?.uid else { return nil }
        
        print("Fetching attendance status - GigID: \(gigId), UserID: \(userId)")
        
        let document = try await db.collection("gigs")
            .document(gigId)
            .collection("attendance")
            .document(userId)
            .getDocument()
        
        guard let data = document.data(),
              let statusString = data["status"] as? String,
              let status = AttendanceStatus(rawValue: statusString) else {
            print("No valid attendance data found")
            return nil
        }
        
        print("Found attendance status: \(status)")
        return status
    }
    
    func getAttendanceCount(gigId: String) async throws -> [AttendanceStatus: Int] {
        let attendances = try await getAttendanceList(gigId: gigId)
        var counts: [AttendanceStatus: Int] = [:]
        
        for status in AttendanceStatus.allCases {
            counts[status] = attendances.filter { $0.status == status }.count
        }
        
        return counts
    }
    
    // MARK: - Listener Methods
    func listenToAttendance(gigId: String, completion: @escaping ([Attendance]) -> Void) {
        db.collection("gigs")
            .document(gigId)
            .collection("attendance")
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                let attendance = documents.compactMap { try? $0.data(as: Attendance.self) }
                completion(attendance)
            }
    }
    
    func listenToUserAttendance(gigId: String, completion: @escaping (AttendanceStatus?) -> Void) -> ListenerRegistration {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user ID available for attendance listener")
            return db.collection("gigs").document(gigId).addSnapshotListener { _, _ in }
        }
        
        print("Setting up attendance listener - GigID: \(gigId), UserID: \(userId)")
        
        return db.collection("gigs")
            .document(gigId)
            .collection("attendance")
            .document(userId)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Listener error: \(error.localizedDescription)")
                    return
                }
                
                guard let data = snapshot?.data(),
                      let statusString = data["status"] as? String,
                      let status = AttendanceStatus(rawValue: statusString) else {
                    print("No attendance data found")
                    completion(nil)
                    return
                }
                
                print("Received attendance update: \(status)")
                completion(status)
            }
    }
}
