import SwiftUI
import FirebaseAuth
import GoogleSignIn
import LocalAuthentication
import FirebaseCore

struct SignInView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordHidden: Bool = true
    @State private var rememberMe: Bool = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var navigateToPersonalizeView = false
    
    @EnvironmentObject var appState: AppState
    
    @FocusState private var focusedField: Field?

    enum Field {
        case email
        case password
    }

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text("Welcome Back!")
                .font(.custom("Rubik-Medium", size: 24))
                .padding(.top, 50)
            Image("logo_bookbee")
                .resizable()
                .scaledToFit()
                .frame(width: 218, height: 64)
                .padding(.bottom, 70)

            VStack(spacing: 20) {
                TextField("Email", text: $email)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .font(.custom("Rubik-Light", size: 16))
                    .keyboardType(.emailAddress)
                    .focused($focusedField, equals: .email)
                
                HStack {
                    if isPasswordHidden {
                        SecureField("Password", text: $password)
                            .focused($focusedField, equals: .password)
                    } else {
                        TextField("Password", text: $password)
                            .focused($focusedField, equals: .password)
                    }
                    
                    Button(action: {
                        isPasswordHidden.toggle()
                    }) {
                        Image(systemName: isPasswordHidden ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(8)
                .font(.custom("Rubik-Light", size: 16))
                
                HStack {
                    Toggle("Remember me", isOn: $rememberMe)
                        .font(.custom("Rubik-Light", size: 14))
                    
                    Spacer()
                    
                    NavigationLink(destination: ResetPasswordView()) {
                        Text("Reset Password?")
                            .font(.custom("Rubik-Light", size: 14))
                            .foregroundColor(Color("F8C95A"))
                    }
                }
            }
            .padding(.horizontal, 20)

            Button(action: {
                Task {
                    do {
                        try await appState.signIn(email: email, password: password)
                        appState.hasCompletedOnboarding = false // Reset onboarding state
                        navigateToPersonalizeView = true
                    } catch {
                        errorMessage = "Failed to sign in. Please check your credentials."
                        showingError = true
                    }
                }
            }) {
                Text("Sign In")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("F8C95A"))
                    .cornerRadius(10)
            }
            .padding(.horizontal, 20)

            Button(action: {
                signInWithGoogle()
            }) {
                HStack {
                    Image("google_logo")
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text("Sign in with Google")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color("F8C95A"))
                .cornerRadius(10)
            }
            .padding(.horizontal, 20)

            Button(action: {
                authenticateWithFaceID()
            }) {
                HStack {
                    Image(systemName: "faceid")
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text("Sign in with Face ID")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color("F8C95A"))
                .cornerRadius(10)
            }
            .padding(.horizontal, 20)

            Spacer()
            
            HStack {
                Text("Don't have an account?")
                NavigationLink(destination: SignUpView().environmentObject(appState)) {
                    Text("Sign Up")
                        .fontWeight(.bold)
                        .foregroundColor(Color("F8C95A"))
                }
            }
            .padding(.bottom, 20)
        }
        .padding()
        .background(Color("background_grey"))
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            focusedField = .email // Automatically focus the email field when the view appears
        }
        .background(
            NavigationLink(destination: MainTabView().environmentObject(appState), isActive: $navigateToPersonalizeView) {
                EmptyView()
            }
        )
    }
    
    private func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.signIn(withPresenting: getRootViewController()) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
                showingError = true
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    errorMessage = error.localizedDescription
                    showingError = true
                    return
                }
                
                appState.isSignedIn = true
                appState.hasCompletedOnboarding = false // Reset onboarding state
                navigateToPersonalizeView = true
            }
        }
    }
    
    private func authenticateWithFaceID() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate with Face ID to access your account."
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        appState.isSignedIn = true
                        appState.hasCompletedOnboarding = false // Reset onboarding state
                        navigateToPersonalizeView = true
                    } else {
                        errorMessage = authenticationError?.localizedDescription ?? "Failed to authenticate with Face ID."
                        showingError = true
                    }
                }
            }
        } else {
            errorMessage = error?.localizedDescription ?? "Face ID not available."
            showingError = true
        }
    }
    
    private func getRootViewController() -> UIViewController {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return UIViewController()
        }
        return rootViewController
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
            .environmentObject(AppState())
    }
}