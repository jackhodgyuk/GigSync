import SwiftUI

struct WelcomeView: View {
    @State private var animateElements = false
    
    var body: some View {
        VStack(spacing: 32) {
            // Logo and Title Section
            VStack(spacing: 16) {
                Image(systemName: "music.note.list")
                    .font(.system(size: 60))
                    .foregroundColor(.accentColor)
                    .scaleEffect(animateElements ? 1 : 0)
                
                Text("Welcome to GigSync")
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)
                    .opacity(animateElements ? 1 : 0)
                
                Text("Manage your band, gigs, and setlists")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .opacity(animateElements ? 1 : 0)
            }
            
            // Buttons Section
            VStack(spacing: 16) {
                NavigationLink("Sign In") {
                    AuthView(isSignUp: false) { _ in }
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                .controlSize(.large)
                
                NavigationLink("Create Account") {
                    AuthView(isSignUp: true) { _ in }
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)
                .controlSize(.large)
            }
            .offset(y: animateElements ? 0 : 50)
            .opacity(animateElements ? 1 : 0)
        }
        .padding(24)
        .frame(maxHeight: .infinity)
        .background(Color(uiColor: .systemBackground))
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animateElements = true
            }
        }
    }
}
