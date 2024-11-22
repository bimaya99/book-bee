import SwiftUI
import Firebase
import FirebaseAuth

struct PersonalizeView: View {
    @State private var yearlyGoal: String = "" // For yearly book goal
    @State private var dailyHours: String = "" // For daily reading goal (hours)
    @State private var isSaving: Bool = false // To show a loading indicator
    @State private var navigateToGenreView: Bool = false // Navigation state

    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 30) {
            // Title
            Text("What is your reading goal for a year?")
                .font(Font.custom("Rubik-Medium", size: 24))
                .foregroundColor(Color.black)
                .multilineTextAlignment(.center)
            
            // Yearly Goal Input
            VStack {
                Text("How many books")
                    .font(Font.custom("Rubik-Regular", size: 12))
                    .foregroundColor(Color("F8C95A")) // Color saved in assets
                
                TextField("", text: $yearlyGoal)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color("F8DEA0"))
                    .cornerRadius(10)
                    .padding(.horizontal, 150)
                    
            }
            
            // Daily Goal Section
            VStack(spacing: 30) {
                Text("What is your reading goal for a day?")
                    .font(Font.custom("Rubik-Medium", size: 24))
                    .foregroundColor(Color.black)
                    .multilineTextAlignment(.center)
                
                Text("How many hours?")
                    .font(Font.custom("Rubik-Regular", size: 12))
                    .foregroundColor(Color("F8C95A"))
                
                TextField("", text: $dailyHours)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color("F8DEA0"))
                    .cornerRadius(10)
                    .padding(.horizontal, 150)
            }
            .padding(.top, 20)
            
            // Continue Button
            Button(action: saveGoals) {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("F8C95A"))
                    .cornerRadius(10)
                    .padding(.top, 40)
            }
            .padding(.horizontal, 20)
            .disabled(isSaving) // Disable button while saving
            
            NavigationLink(destination: PersonalizeGenreView(), isActive: $navigateToGenreView) {
                EmptyView()
            }
        }
        .padding()
        .background(Color("BackgroundColor")) // Background color from assets
        .edgesIgnoringSafeArea(.all)
        .navigationBarBackButtonHidden(true) // Custom back button
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    // Handle back button navigation
                }) {
                    Image(systemName: "arrow.backward")
                        .frame(width: 30, height: 27)
                        .foregroundColor(.black)
                }
            }
        }
    }

    // MARK: - Save Goals Function
    func saveGoals() {
        guard let yearlyGoalInt = Int(yearlyGoal), let dailyHoursInt = Int(dailyHours) else {
            print("Invalid input")
            return
        }
        
        let dailyMinutes = dailyHoursInt * 60 // Convert hours to minutes
        
        isSaving = true // Show loading state

        // Firebase logic
        let db = Database.database().reference()
        let userId = Auth.auth().currentUser?.uid ?? "" // Use the logged-in user's ID

        db.child("users/\(userId)").updateChildValues([
            "yearlyGoal": yearlyGoalInt,
            "dailyReadingGoal": dailyMinutes
        ]) { error, _ in
            isSaving = false // Reset loading state
            
            if let error = error {
                print("Error saving data: \(error.localizedDescription)")
            } else {
                print("Reading goals saved successfully.")
                navigateToGenreView = true // Navigate to PersonalizeGenreView
            }
        }
    }
}

struct PersonalizeView_Previews: PreviewProvider {
    static var previews: some View {
        PersonalizeView()
            .environmentObject(AppState())
    }
}