import SwiftUI
import Firebase
import UserNotifications

@main
struct TheBookBeeApp: App {
    @StateObject private var appState = AppState()
    @State private var showSplash = true
    
    init() {
        FirebaseApp.configure()
        requestNotificationPermission()
        UNUserNotificationCenter.current().delegate = NotificationDelegate()
    }
    
    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showSplash = false
                        }
                    }
            } else {
                NavigationStack {
                    if appState.isSignedIn {
                        PersonalizeView()
                            .environmentObject(appState)
                    } else {
                        if !appState.hasCompletedOnboarding {
                            OnboardingView()
                                .environmentObject(appState)
                        } else {
                            SignInView()
                                .environmentObject(appState)
                        }
                    }
                }
            }
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else if let error = error {
                print("Error requesting notification permission: \(error)")
            }
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        TabView {
            // Search View
            NavigationStack {
                SearchBooksView()
                    .environmentObject(appState)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                appState.showUserProfile = true
                            }) {
                                Image(systemName: "person.circle")
                            }
                        }
                    }
            }
            .tabItem {
                Image("Search")
            }
            
            // Goal View
            NavigationStack {
                GoalView()
                    .environmentObject(appState)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                appState.showUserProfile = true
                            }) {
                                Image(systemName: "person.circle")
                            }
                        }
                    }
            }
            .tabItem {
                Image("Goal")
            }
            
            // Stats View
            NavigationStack {
                StatsView()
                    .environmentObject(appState)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                appState.showUserProfile = true
                            }) {
                                Image(systemName: "person.circle")
                            }
                        }
                    }
            }
            .tabItem {
                Image("Combo_Chart")
            }
            
            // Books View
            NavigationStack {
                BooksView()
                    .environmentObject(appState)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                appState.showUserProfile = true
                            }) {
                                Image(systemName: "person.circle")
                            }
                        }
                    }
            }
            .tabItem {
                Image("Books")
            }
            
            // Home View
            NavigationStack {
                DashboardView()
                    .environmentObject(appState)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                appState.showUserProfile = true
                            }) {
                                Image(systemName: "person.circle")
                            }
                        }
                    }
            }
            .tabItem {
                Image("Home")
            }
        }
        .accentColor(.black) // Customize the tab bar selection color
        .background(Color("F8DEAD").edgesIgnoringSafeArea(.all)) // Match the background color
        .sheet(isPresented: $appState.showUserProfile) {
            UserProfileView()
                .environmentObject(appState)
        }
    }
}

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle the notification action and navigate to NotificationsView
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = UIHostingController(rootView: NotificationsView().environmentObject(AppState()))
            window.makeKeyAndVisible()
        }
        completionHandler()
    }
}