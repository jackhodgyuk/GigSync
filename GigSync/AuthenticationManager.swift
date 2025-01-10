import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
class AuthenticationManager: ObservableObject {
    static let shared = AuthenticationManager()
    @Published var isAuthenticated = Auth.auth().currentUser != nil
    @Published var userBands: [Band] = []
    @AppStorage("savedEmail") private var savedEmailPrivate: String = ""
    @AppStorage("savedPassword") private var savedPasswordPrivate: String = ""
    @AppStorage("savedName") private var savedNamePrivate: String = ""
    @AppStorage("rememberLogin") var rememberLogin: Bool = false
    private var stateListener: AuthStateDidChangeListenerHandle?
    private let db = Firestore.firestore()
    
    var savedEmail: String { savedEmailPrivate }
    var savedPassword: String { savedPasswordPrivate }
    var savedName: String { savedNamePrivate }
    
    init() {
        setupAuthStateListener()
    }
    
    private func setupAuthStateListener() {
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
    
    func signIn(email: String, password: String, remember: Bool = false) async throws {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        if remember {
            savedEmailPrivate = email
            savedPasswordPrivate = password
            let userDoc = try await db.collection("users").document(result.user.uid).getDocument()
            if let name = userDoc.data()?["name"] as? String {
                savedNamePrivate = name
            }
            rememberLogin = true
        }
        isAuthenticated = true
        print("User signed in: \(result.user.uid)")
        await loadUserBands()
    }
    
    func forgetSavedCredentials() {
        savedEmailPrivate = ""
        savedPasswordPrivate = ""
        savedNamePrivate = ""
        rememberLogin = false
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
            let bands = try await BandService.shared.getUserBands(userId: userId)
            print("Loaded \(bands.count) bands directly from bands collection")
            await MainActor.run {
                self.userBands = bands.sorted { $0.name < $1.name }
            }
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
