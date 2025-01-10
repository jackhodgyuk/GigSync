import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
class AuthenticationManager: ObservableObject {
    static let shared = AuthenticationManager()
    @Published var isAuthenticated = Auth.auth().currentUser != nil
    @Published var userBands: [Band] = []
    private var stateListener: AuthStateDidChangeListenerHandle?
    private let db = Firestore.firestore()
    
    init() {
        stateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.isAuthenticated = user != nil
            if user != nil {
                Task {
                    await self?.loadUserBands()
                }
            } else {
                self?.userBands = []
            }
        }
    }
    
    func signIn(email: String, password: String) async throws {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        isAuthenticated = true
        print("User signed in: \(result.user.uid)")
        await loadUserBands()
    }
    
    func signUp(email: String, password: String, name: String) async throws {
        let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
        let userId = authResult.user.uid
        
        let userData = [
            "id": userId,
            "name": name,
            "email": email,
            "bandIds": [],
            "createdAt": Timestamp(date: Date())
        ] as [String: Any]
        
        try await db.collection("users").document(userId).setData(userData)
        
        isAuthenticated = true
        await loadUserBands()
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
        userBands = []
        isAuthenticated = false
    }
    
    func loadUserBands() async {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No authenticated user found")
            return
        }
        
        do {
            let userDoc = try await db.collection("users").document(userId).getDocument()
            guard let bandIds = userDoc.data()?["bandIds"] as? [String] else {
                print("No band IDs found for user")
                return
            }
            
            print("Found band IDs: \(bandIds)")
            
            let bands = try await withThrowingTaskGroup(of: Band?.self) { group in
                for bandId in bandIds {
                    group.addTask {
                        print("Attempting to fetch band: \(bandId)")
                        let bandDoc = try await self.db.collection("bands").document(bandId).getDocument()
                        print("Band document exists: \(bandDoc.exists)")
                        if let data = bandDoc.data() {
                            print("Band data: \(data)")
                        }
                        let band = try? bandDoc.data(as: Band.self)
                        print("Band decoded: \(band != nil)")
                        return band
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
            
            print("Loaded bands: \(bands.count)")
            self.userBands = bands
            
        } catch {
            print("Error loading user bands: \(error.localizedDescription)")
            self.userBands = []
        }
    }
    
    deinit {
        if let listener = stateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
}

