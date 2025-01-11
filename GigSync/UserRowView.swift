import SwiftUI

struct UserRowView: View {
    let member: BandMember
    let isAdmin: Bool
    let onRoleChange: (String) -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(member.name)
                    .font(.headline)
                Text(member.email)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(member.role.capitalized)
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            if isAdmin {
                Menu {
                    Button("Make Member") { onRoleChange("member") }
                    Button("Make Manager") { onRoleChange("manager") }
                    Button("Make Admin") { onRoleChange("admin") }
                    Divider()
                    Button("Remove Member", role: .destructive) { onDelete() }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }
}
