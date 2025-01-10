import SwiftUI

struct BandSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authManager = AuthenticationManager.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Get Started with Your Band")
                    .font(.title)
                    .bold()
                
                NavigationLink {
                    CreateBandView()
                } label: {
                    Text("Create a New Band")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                
                NavigationLink {
                    JoinBandView()
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
