import SwiftUI
import FirebaseFirestore

struct BookTrackingView: View {
    @State private var book: Book // Injected Book object
    @State private var currentPage: Int = 0
    @State private var readingTime: Int = 0
    @State private var startDate: Date = Date()
    @State private var endDate: Date? = nil
    @State private var timer: Timer? = nil
    @State private var seconds: Int = 0
    @State private var isTimerRunning: Bool = false
    
    init(book: Book) {
        _book = State(initialValue: book)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Book Cover and Details
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        AsyncImage(url: URL(string: convertToDirectImageURL(book.coverURL))) { image in
                            image.resizable().scaledToFit()
                        } placeholder: {
                            Color.gray
                        }
                        .frame(width: 121, height: 155)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text(book.title)
                                .font(.system(size: 30, weight: .semibold))
                            Text(book.author)
                                .font(.system(size: 20, weight: .light))
                            Text("\(book.pageCount) pages")
                                .font(.system(size: 16, weight: .light))
                        }
                    }
                }
                .padding(.horizontal)

                // Date Pickers
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Start Date")
                            .font(.system(size: 17, weight: .medium))
                        Spacer()
                        DatePicker("", selection: $startDate, displayedComponents: .date)
                            .labelsHidden()
                            .onChange(of: startDate) { _ in
                                saveDates() // Save date when changed
                            }
                    }

                    HStack {
                        Text("End Date (optional)")
                            .font(.system(size: 17, weight: .medium))
                        Spacer()
                        DatePicker("", selection: binding($endDate, replacingNilWith: Date()), displayedComponents: .date)
                            .labelsHidden()
                            .onChange(of: endDate) { _ in
                                saveDates() // Save date when changed
                            }
                    }
                }
                .padding(.horizontal)

                // Progress and Timer
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Pages Reading")
                            .font(.system(size: 17, weight: .medium))
                        Spacer()
                        TextField("Enter current page", value: $currentPage, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 100)
                    }

                    HStack {
                        Text("Reading Time")
                            .font(.system(size: 17, weight: .medium))
                        Spacer()
                        Text("\(readingTime / 60)h \(readingTime % 60)m")
                    }

                    HStack {
                        Text("Timer")
                            .font(.system(size: 17, weight: .medium))
                        Spacer()
                        Text(String(format: "%02d:%02d:%02d", seconds / 3600, (seconds % 3600) / 60, seconds % 60))
                    }
                }
                .padding(.horizontal)

                // Timer Controls
                HStack(spacing: 20) {
                    Button(action: {
                        if isTimerRunning {
                            pauseTimer()
                        } else {
                            startTimer()
                        }
                    }) {
                        Text(isTimerRunning ? "Pause" : "Continue")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(isTimerRunning ? Color.red : Color.green)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)

                // Continue Reading Button
                Button(action: {
                    updatePagesRead() // Save current page
                }) {
                    Text(currentPage >= book.pageCount ? "Completed" : "Continue Reading")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(currentPage >= book.pageCount ? Color.gray : Color.yellow)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .navigationBarTitle("Book Tracking", displayMode: .inline)
            .onAppear {
                setupBookData()
                startTimer()
            }
            .onDisappear {
                stopTimer()
            }
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

    private func binding<T>(_ binding: Binding<T?>, replacingNilWith defaultValue: T) -> Binding<T> {
        Binding(
            get: { binding.wrappedValue ?? defaultValue },
            set: { binding.wrappedValue = $0 }
        )
    }

    private func startTimer() {
        isTimerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            seconds += 1
        }
    }

    private func pauseTimer() {
        isTimerRunning = false
        timer?.invalidate()
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        saveReadingTime()
    }
}

extension BookTrackingView {
    func setupBookData() {
        currentPage = book.currentPage ?? 0
        readingTime = book.readingTime
        startDate = book.startDate ?? Date()
        endDate = book.endDate
    }

    func saveDates() {
        let db = Firestore.firestore()
        db.collection("books").document(book.id ?? "").updateData([
            "startDate": startDate,
            "endDate": endDate ?? NSNull()
        ]) { error in
            if let error = error {
                print("Error saving dates: \(error.localizedDescription)")
            } else {
                print("Dates saved successfully")
            }
        }
    }

    func updatePagesRead() {
        let db = Firestore.firestore()
        db.collection("books").document(book.id ?? "").updateData([
            "currentPage": currentPage
        ]) { error in
            if let error = error {
                print("Error updating pages read: \(error.localizedDescription)")
            } else {
                print("Pages read updated successfully")
            }
        }
    }

    func saveReadingTime() {
        let db = Firestore.firestore()
        db.collection("books").document(book.id ?? "").updateData([
            "readingTime": readingTime + (seconds / 60)
        ]) { error in
            if let error = error {
                print("Error saving reading time: \(error.localizedDescription)")
            } else {
                print("Reading time saved")
            }
        }
    }
}

#Preview {
    BookTrackingView(book: Book(
        id: "123",
        title: "Sample Book",
        author: "Sample Author",
        description: "Sample description",
        bookID: "123",
        publishYear: 2023,
        pageCount: 300,
        genres: ["Fiction"],
        coverURL: "https://example.com/cover.jpg",
        musicURL: "",
        currentPage: nil,
        startDate: nil,
        endDate: nil,
        readingTime: 0,
        status: "Reading",
        averageRating: 4.5
    ))
}
