import SwiftUI

struct BandSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var showCreateBand: Bool
    @Binding var showJoinBand: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Get Started with Your Band")
                    .font(.title)
                    .bold()
                
                Button {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        showCreateBand = true
                    }
                } label: {
                    Text("Create a New Band")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                
                Button {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        showJoinBand = true
                    }
                } label: {
                    Text("Join Existing Band")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .interactiveDismissDisabled()
        }
    }
}
