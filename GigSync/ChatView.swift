import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import PhotosUI

struct ChatView: View {
    // MARK: - Properties
    @State private var messages: [Message] = []
    @State private var newMessage = ""
    @State private var isLoading = false
    @State private var imageSelection: PhotosPickerItem? = nil
    @State private var showingClearAlert = false
    @State private var showingDeleteSheet = false
    let bandId: String
    let isAdmin: Bool
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            messagesView
            messageInputBar
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Button(action: {
                    if isAdmin {
                        showingDeleteSheet = true
                    }
                }) {
                    Text("Band Chat")
                        .foregroundColor(isAdmin ? .blue : .primary)
                        .fontWeight(.semibold)
                        .zIndex(1)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if isAdmin {
                    Button(action: {
                        print("Admin trash button tapped!")
                        showingClearAlert = true
                    }) {
                        Image(systemName: "trash.circle.fill")
                            .foregroundColor(.red)
                            .font(.title2)
                            .imageScale(.large)
                            .zIndex(2)
                    }
                }
            }
        }
        .confirmationDialog(
            "Delete All Messages",
            isPresented: $showingDeleteSheet,
            titleVisibility: .visible
        ) {
            if isAdmin {
                Button("Delete All Messages", role: .destructive) {
                    Task {
                        try? await ChatService.shared.clearAllMessages(bandId: bandId)
                    }
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently delete all messages in this chat.")
        }
        .alert("Clear All Messages", isPresented: $showingClearAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                Task { try? await ChatService.shared.clearAllMessages(bandId: bandId) }
            }
        } message: {
            Text("This will permanently delete all messages in this chat.")
        }
        .onAppear {
            setupMessagesListener()
            print("Chat View appeared - Admin status: \(isAdmin)")
        }
        .onChange(of: imageSelection) { _, newValue in
            if let newValue { handleImageSelection(newValue) }
        }
    }
    // MARK: - Messages View
    private var messagesView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(messages) { message in
                        MessageBubble(
                            message: message,
                            isCurrentUser: message.senderId == Auth.auth().currentUser?.uid
                        )
                        .id(message.id)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            .onChange(of: messages.count) { _, _ in
                if let lastId = messages.last?.id {
                    withAnimation {
                        proxy.scrollTo(lastId, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    // MARK: - Message Input Bar
    private var messageInputBar: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 12) {
                photoButton
                if isAdmin {
                    Button(action: {
                        showingClearAlert = true
                    }) {
                        Image(systemName: "trash.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.red)
                            .padding(8)
                            .background(Circle().fill(Color.red.opacity(0.1)))
                    }
                }
                messageTextField
                sendButton
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
        }
    }
    
    // MARK: - UI Components
    private var photoButton: some View {
        PhotosPicker(selection: $imageSelection, matching: .images) {
            Image(systemName: "photo")
                .font(.system(size: 20))
                .foregroundColor(.blue)
                .padding(8)
                .background(Circle().fill(Color.blue.opacity(0.1)))
        }
    }
    
    private var messageTextField: some View {
        TextField("Message", text: $newMessage)
            .textFieldStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(20)
            .disabled(isLoading)
    }
    
    private var sendButton: some View {
        Button(action: sendMessage) {
            Image(systemName: "paperplane.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(newMessage.isEmpty ? .gray : .blue)
                .padding(8)
                .background(Circle().fill(newMessage.isEmpty ? Color.gray.opacity(0.1) : Color.blue.opacity(0.1)))
        }
        .disabled(newMessage.isEmpty || isLoading)
    }
    
    // MARK: - Functions
    private func setupMessagesListener() {
        Firestore.firestore().collection("messages")
            .whereField("bandId", isEqualTo: bandId)
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                messages = documents.compactMap { try? $0.data(as: Message.self) }
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
            } catch {
                print("Error sending message: \(error)")
            }
            isLoading = false
        }
    }
    
    private func handleImageSelection(_ item: PhotosPickerItem) {
        Task {
            if let data = try? await item.loadTransferable(type: Data.self) {
                try await ChatService.shared.sendImage(
                    imageData: data,
                    bandId: bandId,
                    senderId: Auth.auth().currentUser?.uid ?? ""
                )
            }
        }
    }
}
