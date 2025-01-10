import SwiftUI

struct UserProfileView: View {
    @StateObject private var authManager = AuthenticationManager.shared
    @State private var showSignInView = false
    @State private var isPressed = false
    @State private var isLoading = false
    @State private var navigateToBands = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Group {
            if authManager.rememberLogin {
                VStack(spacing: 24) {
                    ZStack {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(1.5)
                                .offset(y: 60)
                        }
                        
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 100, height: 100)
                            .overlay(
                                Text(getInitials())
                                    .foregroundColor(.white)
                                    .font(.title)
                            )
                            .scaleEffect(isPressed ? 0.9 : 1.0)
                            .animation(.spring(response: 0.3), value: isPressed)
                            .onTapGesture {
                                isPressed = true
                                isLoading = true
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    navigateToBands = true
                                }
                                
                                Task {
                                    do {
                                        try await authManager.signIn(
                                            email: authManager.savedEmail,
                                            password: authManager.savedPassword,
                                            remember: true
                                        )
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            dismiss()
                                        }
                                    } catch {
                                        print("Error signing in: \(error.localizedDescription)")
                                        isPressed = false
                                        isLoading = false
                                    }
                                }
                            }
                    }
                    
                    Text(authManager.savedName)
                        .font(.title2)
                        .bold()
                        .opacity(navigateToBands ? 0 : 1)
                        .animation(.easeOut(duration: 0.2), value: navigateToBands)
                    
                    Button(action: forgetAccount) {
                        Text("Forget Account")
                            .foregroundColor(.red)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.red, lineWidth: 1)
                            )
                    }
                    .opacity(navigateToBands ? 0 : 1)
                    .animation(.easeOut(duration: 0.2), value: navigateToBands)
                }
                .padding()
            } else {
                AuthView(isSignUp: false) { _ in }
            }
        }
    }
    
    private func getInitials() -> String {
        let components = authManager.savedName.components(separatedBy: " ")
        let initials = components.compactMap { $0.first }
        return String(initials.prefix(2)).uppercased()
    }
    
    private func forgetAccount() {
        authManager.forgetSavedCredentials()
        showSignInView = true
    }
}
