import SwiftUI

struct MessageBubble: View {
    let message: Message
    let isCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isCurrentUser { Spacer() }
            
            VStack(alignment: isCurrentUser ? .trailing : .leading) {
                Text(message.senderName)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Group {
                    if message.type == "image", let imageUrl = message.imageUrl {
                        AsyncImage(url: URL(string: imageUrl)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: 200)
                            case .failure:
                                Image(systemName: "photo")
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        Text(message.content ?? "")
                    }
                }
                .padding(10)
                .background(isCurrentUser ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isCurrentUser ? .white : .primary)
                .cornerRadius(15)
                
                Text(message.timestamp.formatted(.relative(presentation: .named)))
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            if !isCurrentUser { Spacer() }
        }
        .padding(.horizontal)
    }
}
