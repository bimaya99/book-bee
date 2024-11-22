import SwiftUI
import FirebaseFirestore

struct BookRow: View {
    let book: Book
    
    var body: some View {
        NavigationLink(destination: BookDetailView(book: book)) {
            HStack(spacing: 12) {
                // Book cover
                if let url = URL(string: convertToDirectImageURL(book.coverURL)) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            Color.gray
                                .opacity(0.3)
                                .frame(width: 60, height: 90)
                                .cornerRadius(8)
                                .shadow(radius: 2)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 90)
                                .cornerRadius(8)
                                .shadow(radius: 2)
                        case .failure:
                            Color.red
                                .opacity(0.3)
                                .frame(width: 60, height: 90)
                                .cornerRadius(8)
                                .shadow(radius: 2)
                        @unknown default:
                            Color.gray
                                .opacity(0.3)
                                .frame(width: 60, height: 90)
                                .cornerRadius(8)
                                .shadow(radius: 2)
                        }
                    }
                } else {
                    Color.gray
                        .opacity(0.3)
                        .frame(width: 60, height: 90)
                        .cornerRadius(8)
                        .shadow(radius: 2)
                }
                
                // Book details
                VStack(alignment: .leading, spacing: 5) {
                    Text(book.title)
                        .font(.custom("Rubik-Medium", size: 16))
                        .lineLimit(2)
                    
                    Text(book.author)
                        .font(.custom("Rubik-Regular", size: 14))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                    
                    HStack {
                        Text("\(book.publishYear)")
                        Text("•")
                        Text("\(book.pageCount) pages")
                    }
                    .font(.custom("Rubik-Regular", size: 12))
                    .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(8)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }

    private func convertToDirectImageURL(_ url: String) -> String {
        if url.contains("imgur.com") && !url.contains("i.imgur.com") {
            let components = url.split(separator: "/")
            if let lastComponent = components.last {
                return "https://i.imgur.com/\(lastComponent).jpg"
            }
        }
        return url
    }
}

// MARK: - Preview
#Preview {
    BookRow(book: Book(
        id: "123",
        title: "The Great Gatsby",
        author: "F. Scott Fitzgerald",
        description: "A story of the fabulously wealthy Jay Gatsby",
        bookID: "123",
        publishYear: 1925,
        pageCount: 180,
        genres: ["Fiction", "Classics"],
        coverURL: "https://example.com/cover.jpg",
        musicURL: "",
        currentPage: nil,
        startDate: nil,
        endDate: nil,
        readingTime: 0,
        status: "Want to Read",
        averageRating: 4.5
    ))
    .padding()
    .previewLayout(.sizeThatFits)
}
