import SwiftUI
import FirebaseFirestore

struct BookDetailView: View {
    @State var book: Book
    @State private var selectedStatus: String
    @State private var rating: Int

    init(book: Book) {
        self._book = State(initialValue: book)
        self._selectedStatus = State(initialValue: book.status)
        self._rating = State(initialValue: Int(book.averageRating.rounded()))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Book cover
            if let url = URL(string: convertToDirectImageURL(book.coverURL)) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    Color.gray
                        .opacity(0.3)
                }
                .frame(height: 200)
                .cornerRadius(8)
                .shadow(radius: 2)
            }

            // Book details
            Text(book.title)
                .font(.title)
                .fontWeight(.bold)
            
            Text("by \(book.author)")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text(book.description)
                .font(.body)
            
            // Rating as stars
            HStack {
                ForEach(0..<5) { index in
                    Image(systemName: index < rating ? "star.fill" : "star")
                        .foregroundColor(index < rating ? .yellow : .gray)
                }
            }

            HStack {
                NavigationLink(destination: BookTrackingView(book: book)) {
                    Text("Read now")
                        .fontWeight(.bold)
                        .foregroundColor(Color("F8C95A"))
                }
            }
            .padding(.bottom, 20)
            
            // Status dropdown
            Picker("Status", selection: $selectedStatus) {
                Text("Ongoing").tag("Ongoing")
                Text("Add to list").tag("Add to list")
                Text("Completed").tag("Completed")
            }
            .pickerStyle(MenuPickerStyle())
            .onChange(of: selectedStatus) { newValue in
                updateBookStatus(newStatus: newValue)
            }
            
            Spacer()
        }
        .padding()
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
    
    private func updateBookStatus(newStatus: String) {
        let db = Firestore.firestore()
        let bookID = book.id
        db.collection("books").document(bookID).updateData(["status": newStatus]) { error in
                if let error = error {
                    print("Error updating status: \(error.localizedDescription)")
                } else {
                    print("Status updated successfully")
                }
            }
    }
}

struct BookDetailView_Previews: PreviewProvider {
    static var previews: some View {
        BookDetailView(book: Book(
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
    }
}
