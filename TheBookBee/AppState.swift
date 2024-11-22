import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class AppState: ObservableObject {
    @Published var isSignedIn: Bool = false
    @Published var hasCompletedOnboarding: Bool = false
    //@Published var hasCompletedPersonalization: Bool = false
   // @Published var hasCompletedGenreSelection: Bool = false
    @Published var selectedGenres: [String] = ["Fiction", "Fantasy", "Science Fiction"]
    @Published var currentUser: User?  // Add custom user data here if needed
    @Published var showUserProfile: Bool = false
    @Published var books: [Book] = []  // Add this line to store fetched books
    @Published var isLoadingBooks: Bool = false  // Add this line to indicate loading state
    
    private var db = Firestore.firestore()
    
    // Observing authentication state changes
    init() {
        // Listen for authentication state changes
        Auth.auth().addStateDidChangeListener { _, user in
            self.isSignedIn = user != nil
            if let user = user {
                // Only fetch user data if signed in
                self.fetchUserData(for: user)
            }
        }
    }
    
    // Sign in using email and password
    func signIn(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.isSignedIn = result.user != nil
        } catch {
            throw error
        }
    }
    
    // Sign out the user
    func signOut() throws {
        do {
            try Auth.auth().signOut()
            self.isSignedIn = false
            self.hasCompletedOnboarding = false
            self.currentUser = nil  // Reset current user on sign out
        } catch {
            throw error
        }
    }

    // Fetch and update the current user's data
    func fetchUserData(for user: FirebaseAuth.User) {
        let docRef = db.collection("users").document(user.uid)
        docRef.getDocument { document, error in
            if let document = document, document.exists {
                // Load user data into AppState
                if let data = document.data() {
                    // Use Firestore data to update custom User model
                    self.currentUser = User(
                        id: user.uid,
                        username: data["username"] as? String ?? "Unknown",
                        email: data["email"] as? String ?? "",
                        profileImageURL: data["profileImageURL"] as? String ?? "",
                        booksRead: data["booksRead"] as? String ?? "",
                        completedBooks: data["completedBooks"] as? String ?? "",
                        currentlyReading: data["currentlyReading"] as? String ?? "",
                        dailyReadingGoal: data["dailyReadingGoal"] as? Int ?? 0,
                        favoriteGenres: data["favoriteGenres"] as? [String] ?? [],
                        notificationsEnabled: data["notificationsEnabled"] as? Bool ?? true,
                        preferredReadingTime: data["preferredReadingTime"] as? Int,
                        totalReadingTime: data["totalReadingTime"] as? Int ?? 0,
                        wantToRead: data["wantToRead"] as? String ?? "",
                        yearlyGoal: data["yearlyGoal"] as? Int ?? 0
                    )
                    // Check onboarding status after loading user data
                    self.hasCompletedOnboarding = data["hasCompletedOnboarding"] as? Bool ?? false
                }
            } else {
                print("Error fetching user data: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    func updateUserProfile(username: String, email: String) async throws {
        guard let user = Auth.auth().currentUser else { return }

        let userData: [String: Any] = [
            "username": username,
            "email": email
        ]

        let docRef = db.collection("users").document(user.uid)
        try await docRef.updateData(userData)
    }

    func updateUserPassword(newPassword: String) async throws {
        guard let user = Auth.auth().currentUser else { return }
        do {
            try await user.updatePassword(to: newPassword)
            print("Password updated successfully!")
        } catch {
            throw error
        }
    }

    // Save user data to Firestore
    func saveUserData() {
        guard let user = Auth.auth().currentUser else { return }
        
        let userData: [String: Any] = [
            "genres": selectedGenres,
            "hasCompletedOnboarding": hasCompletedOnboarding,
            "email": user.email ?? "",
            "username": user.displayName ?? "Unknown"
        ]
        
        // Set the user data in Firestore under the user's UID
        db.collection("users").document(user.uid).setData(userData, merge: true) { error in
            if let error = error {
                print("Error saving user data: \(error.localizedDescription)")
            } else {
                print("User data successfully saved!")
            }
        }
    }
    
    func saveGenres(genres: [String]) {
        guard let user = Auth.auth().currentUser else {
            print("No authenticated user found")
            return
        }
        
        // Update local state
        self.selectedGenres = genres
        
        // Prepare the data to save
        let userData: [String: Any] = [
            "favoriteGenres": genres,
            "hasCompletedGenreSelection": true
        ]
        
        // Save to Firestore
        db.collection("users").document(user.uid).setData(userData, merge: true) { error in
            if let error = error {
                print("Error saving genres: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    print("Genres successfully saved!")
                    // Update local state to reflect the save
                    //self.hasCompletedGenreSelection = true
                }
            }
        }
    }

    func saveGoals(yearlyGoal: Int, dailyReadingGoal: Int, completion: @escaping (Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No authenticated user found"]))
            return
        }

        let userData: [String: Any] = [
            "yearlyGoal": yearlyGoal,
            "dailyReadingGoal": dailyReadingGoal
        ]

        db.collection("users").document(user.uid).setData(userData, merge: true) { error in
            completion(error)
        }
    }
    
    // Update onboarding completion status
    func completeOnboarding() {
        guard let user = Auth.auth().currentUser else { return }
        
        // Update Firestore to mark onboarding as completed
        db.collection("users").document(user.uid).setData([
            "hasCompletedOnboarding": true
        ], merge: true) { error in
            if let error = error {
                print("Error completing onboarding: \(error.localizedDescription)")
            } else {
                self.hasCompletedOnboarding = true
                print("Onboarding completed successfully!")
            }
        }
    }
    
    func fetchBooks(searchText: String = "", selectedInterests: [String] = [], year: String = "", minPageLimit: String = "", maxPageLimit: String = "") {
        isLoadingBooks = true
        let db = Firestore.firestore()
        
        // Filter books based on user selected genres if available
        var query: Query = db.collection("books")
        
        // Apply filters
        if !searchText.isEmpty {
            query = query.whereField("title", isGreaterThanOrEqualTo: searchText)
                .whereField("title", isLessThanOrEqualTo: searchText + "\u{f8ff}")
        }
        if !selectedInterests.isEmpty {
            query = query.whereField("genres", arrayContainsAny: selectedInterests)
        }
        if let yearInt = Int(year), yearInt > 0 {
            query = query.whereField("publishYear", isEqualTo: yearInt)
        }
        // if let min = Int(minPageLimit), let max = Int(maxPageLimit), min <= max {
        //     query = query.whereField("pageCount", isGreaterThanOrEqualTo: min)
        //         .whereField("pageCount", isLessThanOrEqualTo: max)
        // }

        query.getDocuments { snapshot, error in
            self.isLoadingBooks = false
            if let error = error {
                print("Error fetching books: \(error.localizedDescription)")
                return
            }
            
            // Map the documents into Book models
            guard let documents = snapshot?.documents else { return }
            
            var fetchedBooks: [Book] = []
            for document in documents {
                let data = document.data()
                
                // Manually map the Firestore fields to the Book model
                let book = Book(
                    id: document.documentID,  // Use Firestore documentID for the Book's id
                    title: data["title"] as? String ?? "",
                    author: data["author"] as? String ?? "",
                    description: data["description"] as? String ?? "",
                    bookID: data["bookID"] as? String ?? "",
                    publishYear: data["publishYear"] as? Int ?? 0,
                    pageCount: data["pageCount"] as? Int ?? 0,
                    genres: data["genres"] as? [String] ?? [],
                    coverURL: data["coverURL"] as? String ?? "",
                    musicURL: data["musicURL"] as? String ?? "",
                    currentPage: data["currentPage"] as? Int,
                    startDate: (data["startDate"] as? Timestamp)?.dateValue(),
                    endDate: (data["endDate"] as? Timestamp)?.dateValue(),
                    readingTime: data["readingTime"] as? Int ?? 0,
                    status: data["status"] as? String ?? "",
                    averageRating: data["averageRating"] as? Double ?? 0.0
                )
                fetchedBooks.append(book)
            }
            
            print(fetchedBooks)
             
            // Update the books property to trigger view update
            DispatchQueue.main.async {
                self.books = fetchedBooks
            }
        }
    }
}
