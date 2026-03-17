import SwiftUI

// MARK: - Widget

struct WidgetItem: Identifiable {
    let id: UUID
    let title: String
    var isActive: Bool

    init(title: String, isActive: Bool) {
        self.id = UUID()
        self.title = title
        self.isActive = isActive
    }

    init(from record: WidgetRecord) {
        self.id = UUID()
        self.title = record.title
        self.isActive = record.isActive
    }

    struct IconConfig {
        let symbol: String
        let fontSize: CGFloat
        let color: Color
        let backgroundOpacity: Double
    }

    var iconConfig: IconConfig {
        switch title {
        case "Cotisations":
            return IconConfig(symbol: "waveform.path.ecg", fontSize: 16, color: ColorTokens.corailMHBrand, backgroundOpacity: 0.1)
        case "Arrêts de travail":
            return IconConfig(symbol: "chart.pie.fill", fontSize: 14, color: ColorTokens.bleuTurquoiseDark, backgroundOpacity: 0.1)
        case "Affiliations":
            return IconConfig(symbol: "heart.fill", fontSize: 14, color: ColorTokens.corailMHBrand, backgroundOpacity: 0.15)
        case "Consommation":
            return IconConfig(symbol: "chart.bar.fill", fontSize: 14, color: ColorTokens.bleuTurquoiseMiddle, backgroundOpacity: 0.1)
        case "DSN":
            return IconConfig(symbol: "doc.fill", fontSize: 14, color: ColorTokens.grisDark, backgroundOpacity: 0.1)
        default:
            return IconConfig(symbol: "square", fontSize: 14, color: ColorTokens.grisDark, backgroundOpacity: 0.1)
        }
    }
}

// MARK: - Service

struct ServiceItem: Identifiable {
    let id: String
    let title: String
    let description: String
    let backgroundColor: Color
    let blobColor: Color
    let imageURL: String?

    init(from record: ServiceRecord) {
        self.id = record.id
        self.title = record.title
        self.description = record.description
        self.backgroundColor = ColorTokens.named(record.backgroundColor)
        self.blobColor = ColorTokens.named(record.blobColor)
        self.imageURL = AssetURLs.named(record.imageAssetKey)
    }
}

// MARK: - Calendar Event

struct CalendarEvent: Identifiable {
    let id: UUID
    let day: Int
    let month: String
    let time: String
    let name: String?
    let subject: String

    init(from record: CalendarEventRecord) {
        self.id = UUID()
        self.day = record.day
        self.month = record.month
        self.time = record.time
        self.name = record.name
        self.subject = record.subject
    }
}

// MARK: - Notification

enum NotificationCategory: String {
    case vieCompte = "VIE DU COMPTE"
    case messagerie = "MESSAGERIE"
    case vieContrat = "VIE DU CONTRAT"

    init(from key: String) {
        switch key {
        case "vieCompte": self = .vieCompte
        case "messagerie": self = .messagerie
        case "vieContrat": self = .vieContrat
        default: self = .vieCompte
        }
    }
}

struct NotificationItem: Identifiable {
    let id: UUID
    let category: NotificationCategory
    let title: String
    let time: String
    let isRecent: Bool

    init(category: NotificationCategory, title: String, time: String, isRecent: Bool) {
        self.id = UUID()
        self.category = category
        self.title = title
        self.time = time
        self.isRecent = isRecent
    }

    init(from record: NotificationItemRecord) {
        self.id = UUID()
        self.category = NotificationCategory(from: record.category)
        self.title = record.title
        self.time = record.time
        self.isRecent = record.isRecent
    }
}

struct NotificationSection: Identifiable {
    let id: UUID
    let title: String
    let items: [NotificationItem]

    init(title: String, items: [NotificationItem]) {
        self.id = UUID()
        self.title = title
        self.items = items
    }

    init(from record: NotificationSectionRecord) {
        self.id = UUID()
        self.title = record.title
        self.items = record.items.map { NotificationItem(from: $0) }
    }
}

// MARK: - Action Card

struct ActionCard: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let count: Int

    init(from record: ActionCardRecord) {
        self.id = record.id
        self.title = record.title
        self.subtitle = record.subtitle
        self.count = record.count
    }
}

// MARK: - Action Detail

struct ActionDetailItem: Identifiable {
    let id: UUID
    let companyName: String
    let city: String
    let count: Int
    let duration: String

    init(from record: ActionDetailRecord) {
        self.id = UUID()
        self.companyName = record.companyName
        self.city = record.city
        self.count = record.count
        self.duration = record.duration
    }
}

// MARK: - Preference Key

struct BottomSectionTopPreference: PreferenceKey {
    static var defaultValue: CGFloat = .infinity
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Asset URLs

enum AssetURLs {
    static let cotisationWaves = "https://www.figma.com/api/mcp/asset/52ae8b1f-0980-43c4-b263-1513ff9ba45d"
    static let service1 = "https://www.figma.com/api/mcp/asset/e4148789-5e0f-42c9-a750-1295d39a834c"
    static let service2 = "https://www.figma.com/api/mcp/asset/2fd06192-e587-4e2b-985d-dce644ade050"
    static let service3 = "https://www.figma.com/api/mcp/asset/9fab9c42-6e02-4334-bb99-1024bbb3f8dc"
    static let service4 = "https://www.figma.com/api/mcp/asset/de49423a-7a70-4f39-be0a-a55d3c9f6af7"

    static func named(_ key: String) -> String? {
        switch key {
        case "service1": return service1
        case "service2": return service2
        case "service3": return service3
        case "service4": return service4
        case "cotisationWaves": return cotisationWaves
        default: return nil
        }
    }
}
