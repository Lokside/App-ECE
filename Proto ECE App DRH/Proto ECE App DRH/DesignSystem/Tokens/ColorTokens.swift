import SwiftUI

// MARK: - Hex initializer

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}

// MARK: - Palette brute

enum ColorTokens {
    // Marque
    static let blanc = Color.white
    static let noir = Color(hex: 0x222222)
    static let corailMHBrand = Color(hex: 0xE2250C)

    // Bleu turquoise
    static let bleuTurquoiseDark = Color(hex: 0x006374)
    static let bleuTurquoiseMiddle = Color(hex: 0x008299)
    static let bleuTurquoiseLight = Color(red: 90 / 255, green: 213 / 255, blue: 217 / 255)
    static let bleuTurquoisePastel = Color(hex: 0xDEF7F7)

    // Pastels
    static let violetPastel = Color(hex: 0xEEE7F9)
    static let rosePastel = Color(hex: 0xFDF0F7)
    static let jaunePastel = Color(hex: 0xF9F4B9)

    // Neutres
    static let grisDark = Color(hex: 0x636363)
    static let vertMedium = Color(hex: 0x03DFB2)

    // Blobs services
    static let blobSoins = Color(hex: 0xF9C4C0)
    static let blobPrevention = Color(hex: 0xAEE9E9)
    static let blobActionSociale = Color(hex: 0xF6C5DA)
    static let blobServicesPlus = Color(hex: 0xE8E09E)

    // Affiliations
    static let affiliationSante = Color(hex: 0xF9D3CE)

    // Notifications
    static let separatorLight = Color(hex: 0xE1E1E1)

    // Widget manager
    static let widgetActive = Color(red: 90 / 255, green: 213 / 255, blue: 217 / 255)
    static let widgetBorder = Color(hex: 0xBDE3F2)

    // Corail dégradé (MHCare card)
    static let corailDark = Color(red: 243 / 255, green: 168 / 255, blue: 158 / 255)
    static let corailLight = Color(red: 249 / 255, green: 211 / 255, blue: 206 / 255)
    static let corailPastel = Color(hex: 0xFFF2F0)

    // IA
    static let violetIA = Color(red: 151 / 255, green: 71 / 255, blue: 255 / 255)
    static let pinkIA = Color(red: 220 / 255, green: 100 / 255, blue: 200 / 255)

    // Lookup by name (for JSON-driven colors)
    static func named(_ key: String) -> Color {
        switch key {
        case "violetPastel": return violetPastel
        case "bleuTurquoisePastel": return bleuTurquoisePastel
        case "rosePastel": return rosePastel
        case "jaunePastel": return jaunePastel
        case "blobSoins": return blobSoins
        case "blobPrevention": return blobPrevention
        case "blobActionSociale": return blobActionSociale
        case "blobServicesPlus": return blobServicesPlus
        case "corailMHBrand": return corailMHBrand
        case "bleuTurquoiseDark": return bleuTurquoiseDark
        case "bleuTurquoiseMiddle": return bleuTurquoiseMiddle
        case "bleuTurquoiseLight": return bleuTurquoiseLight
        case "vertMedium": return vertMedium
        case "grisDark": return grisDark
        case "noir": return noir
        case "blanc": return blanc
        default: return grisDark
        }
    }
}
