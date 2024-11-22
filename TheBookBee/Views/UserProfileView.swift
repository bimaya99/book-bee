import SwiftUI
import SDWebImageSwiftUI
import FirebaseFirestore
import FirebaseAuth

struct UserProfileView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isUpdating: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var selectedImage: UIImage?
    
    var body: some View {
        VStack(spacing: 0) {
            // Navigation Bar
            HStack {
              
                Button(action: {
                    Task {
                        do {
                            try await appState.signOut()
                        } catch {
                            print("Error signing out: \(error)")
                        }
                    }
                }) {
                    Text("Logout")
                        .foregroundColor(.blue)
                        .font(.system(size: 16))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 16) 
                        
                }
            }
            .padding()
            .background(Color.white)
            
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Image
                    Button(action: {
                        showImagePicker = true
                    }) {
                        if let selectedImage = selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } else if let user = appState.currentUser,
                                 let imageURL = URL(string: user.profileImageURL) {
                            WebImage(url: imageURL)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // Input Fields
                    VStack(spacing: 16) {
                        TextField("Username", text: $username)
                            .textFieldStyle(.roundedBorder)
                            .frame(height: 44)
                        
                        TextField("Email", text: $email)
                            .textFieldStyle(.roundedBorder)
                            .frame(height: 44)
                            .autocapitalization(.none)
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(.roundedBorder)
                            .frame(height: 44)
                    }
                    .padding(.horizontal)
                    
                    // Update Button
                    Button(action: updateProfile) {
                        HStack {
                            if isUpdating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            }
                            Text(isUpdating ? "Updating..." : "Update Profile")
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .medium))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color("F8C95A"))
                        .cornerRadius(8)
                    }
                    .disabled(isUpdating)
                    .padding(.horizontal)
                }
                .padding(.vertical, 24)
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .onAppear {
            if let user = appState.currentUser {
                username = user.username
                email = user.email
            }
            
        }
    }
    
    private func updateProfile() {
        isUpdating = true
        Task {
            do {
                try await appState.updateUserProfile(
                    username: username,
                    email: email
                )
                await MainActor.run {
                    isUpdating = false
                    password = "" // Clear password field after successful update
                }
            } catch {
                await MainActor.run {
                    isUpdating = false
                    // Handle error here if needed
                    print("Error updating profile: \(error)")
                }
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable { //image picker
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    UserProfileView()
        .environmentObject(AppState())
}
