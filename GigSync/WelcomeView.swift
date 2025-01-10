import SwiftUI

struct WelcomeView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Welcome to GigSync")
                    .font(.largeTitle)
                    .bold()
                
                NavigationLink("Sign In") {
                    AuthView(isSignUp: false, completion: { _ in })
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                
                NavigationLink("Sign Up") {
                    AuthView(isSignUp: true, completion: { _ in })
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)
            }
            .padding()
        }
    }
}
