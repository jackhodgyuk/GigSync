import SwiftUI
import FirebaseAuth

struct AuthView: View {
    let authManager: AuthenticationManager = AuthenticationManager.shared
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
    @State private var rememberMe = false
    @State private var showUserProfile = false
    @State private var showCreateBand = false
    @State private var showJoinBand = false
    
    let completion: (Bool) -> Void
    
    // MARK: - Initialization
    init(isSignUp: Bool, completion: @escaping (Bool) -> Void) {
        _isSignUp = State(initialValue: isSignUp)
        self.completion = completion
    }
    
    // MARK: - Body
    var body: some View {
        Group {
            if showUserProfile {
                UserProfileView()
            } else {
                NavigationStack {
                    VStack(spacing: 20) {
                        signUpFields
                        credentialFields
                        
                        if !isSignUp {
                            Toggle("Remember Me", isOn: $rememberMe)
                                .padding(.horizontal)
                            
                            if authManager.rememberLogin {
                                Button("Forget Saved Account") {
                                    authManager.forgetSavedCredentials()
                                }
                                .foregroundColor(.red)
                            }
                        }
                        
                        errorView
                        authButton
                    }
                    .padding()
                    .navigationTitle(isSignUp ? "Create Account" : "Sign In")
                    .navigationBarBackButtonHidden(isLoading)
                    .navigationDestination(isPresented: $shouldNavigate) {
                        if isSignUp {
                            BandSetupView(showCreateBand: $showCreateBand, showJoinBand: $showJoinBand)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showCreateBand) {
            CreateBandView()
        }
        .sheet(isPresented: $showJoinBand) {
            JoinBandView()
        }
        .onAppear {
            if !isSignUp && authManager.rememberLogin {
                showUserProfile = true
                email = authManager.savedEmail
                password = authManager.savedPassword
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
                    try await authManager.signIn(email: email, password: password, remember: rememberMe)
                    completion(true)
                    dismiss()
                }
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
                completion(false)
            }
        }
    }
}
