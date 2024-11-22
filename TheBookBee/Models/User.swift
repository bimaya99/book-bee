import Foundation
import FirebaseFirestore

struct User: Codable, Identifiable {
    let id: String
    let username: String
    let email: String
    let profileImageURL: String
    let booksRead: String
    let completedBooks: String
    let currentlyReading: String
    let dailyReadingGoal: Int
    let favoriteGenres: [String]
    let notificationsEnabled: Bool
    let preferredReadingTime: Int? // Optional since it's null in Firestore
    let totalReadingTime: Int
    let wantToRead: String
    let yearlyGoal: Int
}

