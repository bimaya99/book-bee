import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
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

                    // Currently Reading Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Currently Reading")
                            .font(.custom("Rubik-Medium", size: 20))
                            .foregroundColor(.black)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                if appState.isLoadingBooks {
                                    ProgressView()
                                } else {
                                    ForEach(appState.books) { book in
                                        NavigationLink(destination: BookDetailView(book: book)) {
                                            CurrentlyReadingCard(book: book)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Reading Progress
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Reading Progress")
                            .font(.custom("Rubik-Medium", size: 20))
                            .foregroundColor(.black)
                        
                        ProgressCard()
                    }
                    .padding(.horizontal)
                    
                    // Reading Stats
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Reading Stats")
                            .font(.custom("Rubik-Medium", size: 20))
                            .foregroundColor(.black)
                        
                        HStack(spacing: 16) {
                            StatCard(title: "Books Read", value: "12", subtitle: "This month")
                            StatCard(title: "Hours Read", value: "48", subtitle: "This month")
                        }
                    }
                    .padding(.horizontal)
                    
                    // Favorite Genres
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Favorite Genres")
                            .font(.custom("Rubik-Medium", size: 20))
                            .foregroundColor(.black)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Array(appState.selectedGenres), id: \.self) { genre in
                                    GenreTag(title: genre)
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                    .padding(.horizontal)

                    // Schedule Notification Button
                    Button(action: {
                        NotificationManager.shared.scheduleNotification(
                            title: "Reading Reminder",
                            body: "Don't forget to read your book today!",
                            hour: 22,
                            minute: 45
                        )
                    }) {
                        Text("Schedule Notification")
                            .font(.custom("Rubik-Medium", size: 18))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(Color("F8C95A"))
                            .cornerRadius(8)
                            .padding(.horizontal)
                    }
                    .padding(.horizontal)

                    // Schedule Notification Button
                    Button(action: {
                        NotificationManager.shared.scheduleNotificationOnTimeout(
                            title: "Reading Reminder",
                            body: "Don't forget to read your book today!",
                            timeInterval: 5
                        )
                    }) {
                        Text("Schedule Notification (TimeInterval (5))")
                            .font(.custom("Rubik-Medium", size: 18))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(Color("F8C95A"))
                            .cornerRadius(8)
                            .padding(.horizontal)
                    }
                    .padding(.horizontal)
                }
            }
            .background(Color("background_grey"))
            .onAppear {
                appState.fetchBooks()
            }
        }
        .navigationTitle("Dashboard")
    }
}

struct CurrentlyReadingCard: View {
    let book: Book

    var body: some View {
        VStack(alignment: .leading) {
            // Book Cover
            AsyncImage(url: URL(string: book.coverURL)) { image in
                image.resizable().scaledToFit()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 140, height: 200)
            .cornerRadius(8)
            
            // Book Info
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.custom("Rubik-Medium", size: 16))
                    .foregroundColor(.black)
                    .lineLimit(2)
                
                Text(book.author)
                    .font(.custom("Rubik-Regular", size: 14))
                    .foregroundColor(.gray)
                
                // Progress Bar
                ProgressView(value: Double(book.currentPage ?? 0) / Double(book.pageCount))
                    .progressViewStyle(LinearProgressViewStyle())
                    .tint(Color("F8C95A"))
            }
            .padding(.horizontal, 4)
        }
        .frame(width: 140)
    }
}

struct ProgressCard: View {
    var body: some View {
        HStack {
            // Circular Progress
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(Color("F8C95A"), lineWidth: 8)
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                
                Text("70%")
                    .font(.custom("Rubik-Medium", size: 16))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Daily Goal")
                    .font(.custom("Rubik-Medium", size: 18))
                
                Text("You've read 42 minutes today")
                    .font(.custom("Rubik-Regular", size: 14))
                    .foregroundColor(.gray)
            }
            .padding(.leading)
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.custom("Rubik-Regular", size: 14))
                .foregroundColor(.gray)
            
            Text(value)
                .font(.custom("Rubik-Medium", size: 24))
                .foregroundColor(.black)
            
            Text(subtitle)
                .font(.custom("Rubik-Regular", size: 12))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct GenreTag: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.custom("Rubik-Regular", size: 14))
            .foregroundColor(.black)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color("F8DEA0"))
            .cornerRadius(20)
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(AppState())
    }
}