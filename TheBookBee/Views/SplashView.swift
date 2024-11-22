//
//  SplashView.swift
//  TheBookBee
//
//  Created by cocobsccomp231p-019 on 2024-11-16.
//

import SwiftUI


struct SplashView: View {
    @EnvironmentObject var appState: AppState
    @State private var navigateToOnboarding = false

    var body: some View {
        VStack {
            Spacer()
            Image("logo_bookbee")
                .resizable()
                .scaledToFit()
                .frame(width: 218, height: 64)
            Spacer()
        }
        .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        navigateToOnboarding = true
                    }
                }
        .navigationDestination(isPresented: $navigateToOnboarding) {
                    OnboardingView()
                }
            
        
        .edgesIgnoringSafeArea(.all)
    }
}
struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
