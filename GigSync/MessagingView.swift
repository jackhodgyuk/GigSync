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
            print("🎸 MessagingView appeared for bandId: \(bandId)")
        }
    }
    
    private func setupMessagesListener() {
        print("🎵 Setting up listener for bandId: \(bandId)")
        db.collection("messages")
            .whereField("bandId", isEqualTo: bandId)
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ Error listening for messages: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("📭 No messages found")
                    return
                }
                
                print("📨 Received \(documents.count) messages")
                
                let messageData = documents.compactMap { document -> [String: Any]? in
                    var data = document.data()
                    data["id"] = document.documentID
                    return data
                }
                print("📝 Message data: \(messageData)")
                
                messages = documents.compactMap { document in
                    do {
                        var message = try document.data(as: Message.self)
                        message.id = document.documentID
                        return message
                    } catch {
                        print("❌ Error decoding message: \(error)")
                        return nil
                    }
                }
                print("✅ Decoded \(messages.count) messages successfully")
            }
    }
    
    private func sendMessage() {
        guard !newMessage.isEmpty,
              let currentUser = Auth.auth().currentUser else { return }
        
        print("📤 Attempting to send message: \(newMessage)")
        
        let messageData: [String: Any] = [
            "content": newMessage,
            "senderId": currentUser.uid,
            "senderName": currentUser.displayName ?? "Unknown User",
            "timestamp": Timestamp(date: Date()),
            "bandId": bandId
        ]
        
        Task {
            do {
                try await db.collection("messages").document().setData(messageData)
                print("✅ Message sent successfully!")
                await MainActor.run {
                    newMessage = ""
                }
            } catch {
                print("❌ Error sending message: \(error)")
            }
        }
    }
}
