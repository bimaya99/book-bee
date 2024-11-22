import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SignUpView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var username: String = ""  // Added for the custom user
    @State private var showingError = false
    @State private var errorMessage = ""

    @EnvironmentObject var appState: AppState  // Ensure AppState is injected here

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text("Join, BookBee")
                .font(.custom("Rubik-Medium", size: 24))
                .padding(.top, 50)
            Image("logo_bookbee")
                .resizable()
                .scaledToFit()
                .frame(width: 218, height: 64)
                .padding(.bottom, 70)

            VStack(spacing: 20) {
                TextField("Username", text: $username)  // New TextField for username
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .font(.custom("Rubik-Light", size: 16))

                TextField("Email", text: $email)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .font(.custom("Rubik-Light", size: 16))
                    .keyboardType(.emailAddress)

                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .font(.custom("Rubik-Light", size: 16))

                SecureField("Confirm Password", text: $confirmPassword)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .font(.custom("Rubik-Light", size: 16))
            }
            .padding(.horizontal, 20)
            
            
            Button(action: {
                signUp()
            }) {
                Text("Sign Up")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("F8C95A"))
                    .cornerRadius(10)
            }
            .padding(.horizontal, 20)

            Spacer()
            
            HStack {
                Text("Already have an account?")
                NavigationLink(destination: SignInView()) {
                    Text("Sign In")
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
    }

    private func signUp() {
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            showingError = true
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                errorMessage = error.localizedDescription
                showingError = true
                return
            }

            guard let user = authResult?.user else { return }
            saveUserInfo(user: user)
            appState.isSignedIn = true
        }
    }

    private func saveUserInfo(user: FirebaseAuth.User) {
        let db = Firestore.firestore()

        // Create a custom user from the FirebaseAuth.User
        let customUser = User(
            id: user.uid,
            username: username,  // User inputted username
            email: user.email ?? "",
            profileImageURL: "",  // Default or set later if user uploads an image
            booksRead: "",
            completedBooks: "",
            currentlyReading: "",
            dailyReadingGoal: 0,  // Default value, you may want to ask the user for this info later
            favoriteGenres: [],  // Default empty, this can be set later
            notificationsEnabled: true,  // Default value
            preferredReadingTime: nil,  // Default value (null)
            totalReadingTime: 0,  // Default value
            wantToRead: "",
            yearlyGoal: 0  // Default value
        )

        // Save the custom user data to Firestore
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(customUser)
            let userData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

            // Save to Firestore
            db.collection("users").document(user.uid).setData(userData ?? [:]) { error in
                if let error = error {
                    print("Error saving user info: \(error.localizedDescription)")
                } else {
                    print("User info successfully saved!")
                }
            }
        } catch {
            print("Error encoding custom user: \(error)")
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
            .environmentObject(AppState())
    }
}
