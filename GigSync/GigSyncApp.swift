import SwiftUI
import FirebaseCore
import FirebaseFirestore

@main
struct GigSyncApp: App {
    // MARK: - Firebase Configuration
    init() {
        FirebaseApp.configure()
        configureFirestore()
    }
    
    private func configureFirestore() {
        let settings = FirestoreSettings()
        settings.cacheSettings = MemoryCacheSettings()
        Firestore.firestore().settings = settings
    }
    
    // MARK: - App Scene
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
