import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            // Background Image covering the entire screen
            Image("onboardingImage") // Make sure "onboardingImage" is added to your assets
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 16) {
                Spacer() // Add extra Spacer to push content down
                
                // Title
                Text("Track Your Reading Journey with Ease")
                    .font(.custom("Rubik-Medium", size: 24))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                    .padding(.top, 400)
                
                // Subtitle
                Text("Keep all your books in one place, from currently reading to future reads")
                    .font(.custom("Rubik-Regular", size: 16))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black.opacity(0.8))
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20) // Adds 20 points of space between subtitle and button
                
                // "Get Started" Button
                Button(action: {
                    // This will trigger the navigation to PersonalizeView
                    // based on the logic in TheBookBeeApp
                    appState.hasCompletedOnboarding = true
                }) {
                    Text("Get Started")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("F8C95A"))
                        .cornerRadius(10)
                }
                .padding(.horizontal, 20)
                
                Spacer() // This Spacer keeps the button at the bottom
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .environmentObject(AppState())
    }
}
