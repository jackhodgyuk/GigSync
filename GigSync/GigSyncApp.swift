import SwiftUI
import FirebaseCore
import FirebaseFirestore
import UIKit
import Network

class AppDelegate: NSObject, UIApplicationDelegate {
    private let networkMonitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "NetworkMonitoring")
    
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        setupFirebase()
        startNetworkMonitoring()
        return true
    }
    
    private func setupFirebase() {
        FirebaseApp.configure()
        let settings = FirestoreSettings()
        settings.cacheSettings = PersistentCacheSettings()
        Firestore.firestore().settings = settings
        print("Firebase configured successfully")
    }
    
    private func startNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    print("Network connection established")
                } else {
                    print("Network connection unavailable")
                }
            }
        }
        networkMonitor.start(queue: monitorQueue)
    }
}

@main
struct GigSyncApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
