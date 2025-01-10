import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
class AuthenticationManager: ObservableObject {
    static let shared = AuthenticationManager()
    @Published var isAuthenticated = Auth.auth().currentUser != nil
    @Published var userBands: [Band] = []
    private var stateListener: AuthStateDidChangeListenerHandle?
    
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
        try await Auth.auth().signIn(withEmail: email, password: password)
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
        
        let db = Firestore.firestore()
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
        guard let userId = Auth.auth().currentUser?.uid else { return }
        do {
            let bands = try await BandService.shared.getUserBands(userId: userId)
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
