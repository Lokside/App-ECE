import Foundation

// MARK: - Root

struct AppDataRoot: Decodable {
    let widgets: [WidgetRecord]
    let services: [ServiceRecord]
    let upcomingEvents: [CalendarEventRecord]
    let calendarEvents: [CalendarEventRecord]
    let notifications: NotificationsRecord
    let actionCards: [ActionCardRecord]
    let actionDetails: [String: [ActionDetailRecord]]
    let consommationBarChart: [Double]
}

// MARK: - Widget

struct WidgetRecord: Decodable, Identifiable {
    let id: String
    let title: String
    let isActive: Bool
}

// MARK: - Service

struct ServiceRecord: Decodable, Identifiable {
    let id: String
    let title: String
    let description: String
    let backgroundColor: String
    let blobColor: String
    let imageAssetKey: String
}

// MARK: - Calendar Event

struct CalendarEventRecord: Decodable, Identifiable {
    var id: String { "\(day)-\(month)-\(subject)" }
    let day: Int
    let month: String
    let time: String
    let name: String?
    let subject: String
}

// MARK: - Notifications

struct NotificationsRecord: Decodable {
    let sections: [NotificationSectionRecord]
}

struct NotificationSectionRecord: Decodable, Identifiable {
    var id: String { title }
    let title: String
    let items: [NotificationItemRecord]
}

struct NotificationItemRecord: Decodable, Identifiable {
    var id: String { "\(category)-\(title)-\(time)" }
    let category: String
    let title: String
    let time: String
    let isRecent: Bool
}

// MARK: - Action Card

struct ActionCardRecord: Decodable, Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let count: Int
}

// MARK: - Action Detail

struct ActionDetailRecord: Decodable, Identifiable {
    var id: String { "\(companyName)-\(city)" }
    let companyName: String
    let city: String
    let count: Int
    let duration: String
}
