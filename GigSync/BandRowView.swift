import SwiftUI

struct BandRowView: View {
    let band: Band
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(band.name)
                    .font(.headline)
                Text("\(band.memberCount) members")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
    }
}
