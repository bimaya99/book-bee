
import Foundation
import FirebaseFirestore


struct Book: Identifiable, Codable {
    var id: String  // Book identifier
    var title: String
    var author: String
    var description: String
    var bookID: String
    var publishYear: Int
    var pageCount: Int
    var genres: [String]
    var coverURL: String
    var musicURL: String
    var currentPage: Int?
    var startDate: Date?
    var endDate: Date?
    var readingTime: Int
    var status: String
    var averageRating: Double   
}
