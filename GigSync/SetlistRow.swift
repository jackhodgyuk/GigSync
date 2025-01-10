import SwiftUI

struct SetlistRow: View {
    let setlist: Setlist
    let isSelected: Bool
    let onSelect: () -> Void
    
    var totalDuration: Int {
        setlist.songs.reduce(0) { $0 + $1.duration }
    }
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(setlist.name)
                        .font(.headline)
                    
                    Text("\(setlist.songs.count) songs • \(totalDuration) minutes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
        }
        .foregroundColor(.primary)
    }
}
