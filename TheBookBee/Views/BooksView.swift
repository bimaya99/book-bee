import SwiftUI
import FirebaseFirestore

struct BooksView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            VStack {
                if appState.isLoadingBooks {
                    ProgressView()
                } else {
                    ScrollView {
                        LazyVStack {
                            ForEach(appState.books) { book in
                                BookRow(book: book)
                                    .padding(.horizontal)
                                    .padding(.vertical, 5)
                            }
                        }
                    }
                }
            }
            .onAppear {
                appState.fetchBooks()
            }
        }
        .navigationTitle("Books")
    }
}

struct BooksView_Previews: PreviewProvider {
    static var previews: some View {
        BooksView()
            .environmentObject(AppState())
    }
}