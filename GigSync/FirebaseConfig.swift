import FirebaseFirestore

class FirebaseConfig {
    static func configure() {
        let settings = FirestoreSettings()
        settings.cacheSettings = MemoryCacheSettings()
        Firestore.firestore().settings = settings
    }
}
