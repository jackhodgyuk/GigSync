import SwiftUI

struct BandSetupView: View {
    @StateObject private var authManager = AuthenticationManager.shared
    
    var body: some View {
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
        .navigationBarBackButtonHidden()
    }
}
