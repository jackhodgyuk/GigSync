import SwiftUI

struct AttendanceToggle: View {
    @Binding var status: AttendanceStatus
    
    var body: some View {
        HStack {
            ForEach(AttendanceStatus.allCases, id: \.self) { status in
                AttendanceButton(status: status, isSelected: self.status == status) {
                    self.status = status
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}
