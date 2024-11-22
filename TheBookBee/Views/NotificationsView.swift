import SwiftUI

struct NotificationsView: View {
   var notifications: [NotificationSection] = mockNotifications // Replace with your data source

   var body: some View {
       VStack {
           // Navigation Bar
           HStack {
               Button(action: {
                   // Navigation back logic
               }) {
                   Image(systemName: "arrow.left")
                       .resizable()
                       .frame(width: 30, height: 27)
                       .foregroundColor(.black)
               }
               Spacer()
               Text("Notifications")
                   .font(.custom("Rubik-Medium", size: 25))
                   .foregroundColor(Color.black)
               Spacer()
               Button(action: {
                   // Menu action logic
               }) {
                   Image(systemName: "line.3.horizontal")
                       .resizable()
                       .frame(width: 23.3, height: 22.86)
                       .foregroundColor(.black)
               }
           }
           .padding()
           .background(Color("F7F9FA"))

           // Notifications List
           ScrollView {
               ForEach(notifications) { section in
                   VStack(alignment: .leading, spacing: 12) {
                       Text(section.title)
                           .font(.custom("Rubik-Medium", size: 20))
                           .foregroundColor(Color("090A0A"))

                       ForEach(section.notifications) { notification in
                           NotificationRow(notification: notification)
                       }
                   }
                   .padding(.horizontal)
                   .padding(.top, 16)
               }
           }
           .background(Color("F7F9FA"))
       }
       .background(Color("F7F9FA"))
       .ignoresSafeArea(edges: .bottom)
   }
}

struct NotificationRow: View {
   let notification: Notification

   var body: some View {
       HStack(alignment: .top, spacing: 12) {
           Circle()
               .fill(Color.gray.opacity(0.5))
               .frame(width: 40, height: 40)

           VStack(alignment: .leading, spacing: 4) {
               Text(notification.title)
                   .font(.custom("Rubik-Medium", size: 20))
                   .foregroundColor(Color("000000"))
               Text(notification.description)
                   .font(.custom("Rubik-Regular", size: 15))
                   .foregroundColor(Color("000000"))
           }
       }
       .padding(.vertical, 8)
   }
}

struct Notification: Identifiable {
   let id = UUID()
   let title: String
   let description: String
}

struct NotificationSection: Identifiable {
   let id = UUID()
   let title: String
   let notifications: [Notification]
}

// Mock Data for Preview
let mockNotifications = [
   NotificationSection(
       title: "Today",
       notifications: [
           Notification(title: "Reading Reminder", description: "Pick up where you left off in Rich Dad! Your next chapter awaits."),
           Notification(title: "What You Like", description: "Love Romance? Check out this week's top picks in your favorite genre!")
       ]
   ),
   NotificationSection(
       title: "Yesterday",
       notifications: [
           Notification(title: "Reminder", description: "We miss you! Dive back into Rich Dad and rediscover your love for reading.")
       ]
   ),
   NotificationSection(
       title: "Nov 11",
       notifications: [
           Notification(title: "Congratulations", description: "Congratulations! You've completed 50% of your yearly reading goal. Keep going!")
       ]
   )
]


struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView()
            .environmentObject(AppState())
    }
}
