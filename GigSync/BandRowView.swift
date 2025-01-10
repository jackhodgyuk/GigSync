import SwiftUI

struct BandRowView: View {
    let band: Band
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.accentColor.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(band.name.prefix(1))
                        .font(.headline.bold())
                        .foregroundColor(Color.accentColor)
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(band.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("\(band.memberCount) members")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
                .rotationEffect(.degrees(isPressed ? 90 : 0))
        }
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
        .padding(.horizontal, 4)
        .pressEvents(onPress: { pressed in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isPressed = pressed
            }
        })
    }
}

extension View {
    func pressEvents(onPress: @escaping (Bool) -> Void) -> some View {
        self.gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in onPress(true) }
                .onEnded { _ in onPress(false) }
        )
    }
}
