import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct MessagingView: View {
    @State private var messages: [Message] = []
    @State private var newMessage = ""
    let bandId: String
    
    private let db = Firestore.firestore()
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack {
                    ForEach(messages) { message in
                        MessageBubble(
                            message: message,
                            isCurrentUser: message.senderId == Auth.auth().currentUser?.uid
                        )
                    }
                }
                .padding()
            }
            
            HStack {
                TextField("Message", text: $newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.blue)
                }
                .padding(.trailing)
                .disabled(newMessage.isEmpty)
            }
            .padding(.bottom)
        }
        .navigationTitle("Band Chat")
        .onAppear {
            setupMessagesListener()
        }
    }
    
    private func setupMessagesListener() {
        db.collection("messages")
            .whereField("bandId", isEqualTo: bandId)
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                messages = documents.compactMap { try? $0.data(as: Message.self) }
            }
    }
    
    private func sendMessage() {
        guard !newMessage.isEmpty,
              let currentUser = Auth.auth().currentUser else { return }
        
        let message = Message(
            id: UUID().uuidString,
            content: newMessage,
            senderId: currentUser.uid,
            senderName: currentUser.displayName ?? "Unknown User",
            timestamp: Date(),
            bandId: bandId
        )
        
        Task {
            let data = try JSONEncoder().encode(message)
            let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
            try await db.collection("messages").document().setData(dict)
            newMessage = ""
        }
    }
}
