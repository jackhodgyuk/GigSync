import SwiftUI
import FirebaseAuth

struct AuthView: View {
    @StateObject private var authManager = AuthenticationManager.shared
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var isSignUp: Bool
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showBandSetup = false
    let completion: (Bool) -> Void
    
    init(isSignUp: Bool, completion: @escaping (Bool) -> Void) {
        _isSignUp = State(initialValue: isSignUp)
        self.completion = completion
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if isSignUp {
                TextField("Full Name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button(action: handleAuth) {
                if isLoading {
                    ProgressView()
                } else {
                    Text(isSignUp ? "Create Account" : "Sign In")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading || !isValidInput)
        }
        .padding()
        .navigationTitle(isSignUp ? "Create Account" : "Sign In")
        .navigationBarBackButtonHidden(isLoading)
        .navigationDestination(isPresented: $showBandSetup) {
            BandSetupView()
        }
    }
    
    private var isValidInput: Bool {
        if isSignUp {
            return !email.isEmpty && !password.isEmpty && !name.isEmpty && password.count >= 6
        }
        return !email.isEmpty && !password.isEmpty && password.count >= 6
    }
    
    private func handleAuth() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                if isSignUp {
                    try await authManager.signUp(email: email, password: password, name: name)
                    showBandSetup = true
                    completion(true)
                } else {
                    try await authManager.signIn(email: email, password: password)
                    authManager.isAuthenticated = true
                    completion(true)
                }
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
                completion(false)
            }
        }
    }
}
