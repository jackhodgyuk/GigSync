import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ChatView: View {
    @State private var messages: [ChatMessage] = []
    @State private var newMessage = ""
    @State private var isLoading = false
    let bandId: String
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            MessageBubbleView(message: message)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: messages) { oldValue, newValue in
                    withAnimation {
                        proxy.scrollTo(messages.last?.id, anchor: .bottom)
                    }
                }
            }
            
            HStack {
                TextField("Message", text: $newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(isLoading)
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(newMessage.isEmpty ? .gray : .blue)
                }
                .disabled(newMessage.isEmpty || isLoading)
            }
            .padding()
        }
        .navigationTitle("Band Chat")
        .onAppear {
            setupMessagesListener()
        }
    }
    
    private func setupMessagesListener() {
        Firestore.firestore().collection("messages")
            .whereField("bandId", isEqualTo: bandId)
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                messages = documents.compactMap { try? $0.data(as: ChatMessage.self) }
            }
    }
    
    private func sendMessage() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        
        Task {
            do {
                try await ChatService.shared.sendMessage(
                    content: newMessage,
                    bandId: bandId,
                    senderId: userId
                )
                newMessage = ""
                isLoading = false
            } catch {
                isLoading = false
            }
        }
    }
}
