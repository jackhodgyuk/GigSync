import SwiftUI

struct UserRowView: View {
    let member: BandMember
    let onRoleChange: (String) -> Void
    
    private let roles = ["admin", "manager", "member"]
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(member.name)
                    .font(.headline)
                Text(member.email)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Menu {
                ForEach(roles, id: \.self) { role in
                    Button(role.capitalized) {
                        onRoleChange(role)
                    }
                }
            } label: {
                HStack {
                    Text(member.role.capitalized)
                    Image(systemName: "chevron.down")
                }
                .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
    }
}
