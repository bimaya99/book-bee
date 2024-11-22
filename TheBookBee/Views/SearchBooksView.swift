import SwiftUI
import Firebase

struct SearchBooksView: View {
    @EnvironmentObject var appState: AppState
    @State private var searchText: String = ""
    @State private var selectedInterests: [String] = []
    @State private var year: String = ""
    @State private var minPageLimit: String = ""
    @State private var maxPageLimit: String = ""
    
    
    private let interests = ["Romance", "Fantasy", "Fiction", "History", "Spirituals", "Business", "Biography", "Sci-Fi", "Non-Fiction", "Self-Help", "Psychology", "Memoirs"]   //filter genres

    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                VStack(alignment: .leading) {
                    // Search Bar
                    TextField("Search", text: $searchText)
                        .padding()
                        .background(
                            Color.gray
                                .opacity(0.8)
                                .frame(width: geometry.size.width)
                                .cornerRadius(8)
                                .shadow(radius: 2)
                        )
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .frame(width: geometry.size.width) // Adjust width dynamically
                    
                    // Interests filter
                    Text("Interest")
                        .font(.custom("Rubik-Medium", size: 20))
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(interests, id: \.self) { interest in
                                Button(action: {
                                    toggleInterest(interest)
                                }) {
                                    Text(interest)
                                        .font(.custom("Rubik-Medium", size: 15))
                                        .foregroundColor(selectedInterests.contains(interest) ? Color.black : Color.gray)
                                        .padding()
                                        .frame(width: 78, height: 40)
                                        .background(selectedInterests.contains(interest) ? Color("F8DEA0") : Color.white)
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.gray, lineWidth: 1)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Year and Page Limit
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Year")
                                .font(.custom("Rubik-Medium", size: 20))
                            TextField("2000", text: $year)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                                .frame(width: 96)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .leading) {
                            Text("Page Limit")
                                .font(.custom("Rubik-Medium", size: 20))
                            HStack(spacing: 5) {
                                TextField("Min", text: $minPageLimit)
                                    .keyboardType(.numberPad)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray, lineWidth: 1)
                                    )
                                    .frame(width: 96)
                                TextField("Max", text: $maxPageLimit)
                                    .keyboardType(.numberPad)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray, lineWidth: 1)
                                    )
                                    .frame(width: 96)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Filter Button
                    Button(action: {
                        appState.fetchBooks(searchText: searchText, selectedInterests: selectedInterests, year: year, minPageLimit: minPageLimit, maxPageLimit: maxPageLimit)
                    }) {
                        Text("Filter")
                            .font(.custom("Rubik-Medium", size: 18))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(Color("F8C95A"))
                            .cornerRadius(8)
                            .padding(.horizontal)
                    }
                    .padding(.top)
                    
                    // Book List
                    if appState.isLoadingBooks {
                        Spacer()
                        ProgressView()
                        Spacer()
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
                    
                    Spacer()
                }
            }
            .navigationTitle("Search books")
            .navigationBarBackButtonHidden(false)

        }
    }
    

    
    private func toggleInterest(_ interest: String) {
        if let index = selectedInterests.firstIndex(of: interest) {
            selectedInterests.remove(at: index)
        } else {
            selectedInterests.append(interest)
        }
    }
}

struct SearchBooksView_Previews: PreviewProvider {
    static var previews: some View {
        SearchBooksView()
            .environmentObject(AppState())
    }
}
