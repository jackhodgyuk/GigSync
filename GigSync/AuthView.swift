import SwiftUI
import FirebaseAuth

struct AuthView: View {
    @StateObject private var authManager = AuthenticationManager.shared
    @Environment(\.dismiss) var dismiss
    
    // MARK: - Properties
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var isSignUp: Bool
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showBandSetup = false
    @State private var shouldNavigate = false
    
    let completion: (Bool) -> Void
    
    // MARK: - Initialization
    init(isSignUp: Bool, completion: @escaping (Bool) -> Void) {
        _isSignUp = State(initialValue: isSignUp)
        self.completion = completion
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                signUpFields
                credentialFields
                errorView
                authButton
            }
            .padding()
            .navigationTitle(isSignUp ? "Create Account" : "Sign In")
            .navigationBarBackButtonHidden(isLoading)
            .navigationDestination(isPresented: $shouldNavigate) {
                if isSignUp {
                    BandSetupView()
                }
            }
        }
    }
    
    // MARK: - Views
    private var signUpFields: some View {
        Group {
            if isSignUp {
                TextField("Full Name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
    }
    
    private var credentialFields: some View {
        Group {
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
    
    private var errorView: some View {
        Group {
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
    }
    
    private var authButton: some View {
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
    
    // MARK: - Helper Methods
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
                    shouldNavigate = true
                    completion(true)
                } else {
                    try await authManager.signIn(email: email, password: password)
                    authManager.isAuthenticated = true
                    dismiss()
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
