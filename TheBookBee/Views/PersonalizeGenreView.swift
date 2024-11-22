import SwiftUI
import Firebase
import FirebaseDatabase
import FirebaseAuth

struct PersonalizeGenreView: View {
    @State private var selectedGenres: [String] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil // To show error messages

    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack {
            Text("Select Your Favorite Genres")
                .font(.title)
                .padding()

            // Genre selection UI
            ScrollView {
                VStack {
                    ForEach(genres, id: \.self) { genre in
                        GenreTagP(title: genre, isSelected: selectedGenres.contains(genre)) {
                            toggleGenreSelection(genre)
                        }
                    }
                }
            }

            // Save button
            Button(action: saveSelectedGenres) {
                Text("Save")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding()

            if isLoading {
                ProgressView()
            }

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding()
    }

    private func toggleGenreSelection(_ genre: String) {
        if let index = selectedGenres.firstIndex(of: genre) {
            selectedGenres.remove(at: index)
        } else {
            selectedGenres.append(genre)
        }
    }

    private func saveSelectedGenres() {
        isLoading = true

        // Ensure the user is signed in
        guard let userID = Auth.auth().currentUser?.uid else {
            errorMessage = "User not signed in. Please sign in to save your genres."
            isLoading = false
            return
        }

        appState.saveGenres(genres: selectedGenres) { error in
            isLoading = false
            if let error = error {
                errorMessage = "Error saving selected genres: \(error.localizedDescription)"
            } else {
                print("Selected genres saved successfully")
            }
        }
    }

    private var genres: [String] {
        return ["Fiction", "Fantasy", "Science Fiction", "Romance", "Mystery", "Thriller", "Non-Fiction", "Biography", "Self-Help", "History"]
    }
}

struct GenreTagP: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(isSelected ? .white : .black)
                .padding()
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .cornerRadius(8)
        }
        .padding(.vertical, 4)
    }
}

struct PersonalizeGenreView_Previews: PreviewProvider {
    static var previews: some View {
        PersonalizeGenreView()
            .environmentObject(AppState())
    }
}