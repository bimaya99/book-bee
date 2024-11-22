import Foundation

struct Notification: Identifiable, Codable {
    let id: String
    let enabled: Bool
    let message: String
    let type: NotificationType
    let userID: String
    
    enum NotificationType: String, Codable {
        case readingReminder = "ReadingReminder"
        case recommendation = "Recommendation"
        case goalUpdate = "GoalUpdate"
        case reminder = "Reminder"
    }
} 
