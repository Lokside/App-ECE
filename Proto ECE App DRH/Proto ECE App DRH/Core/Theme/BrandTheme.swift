import SwiftUI

/// Alias sémantiques — consomment les tokens bruts.
enum BrandTheme {
    // Texte
    static let textPrimary = ColorTokens.noir
    static let textSecondary = ColorTokens.grisDark
    static let textOnDark = ColorTokens.blanc

    // Marque
    static let accent = ColorTokens.corailMHBrand
    static let tealDark = ColorTokens.bleuTurquoiseDark
    static let tealMiddle = ColorTokens.bleuTurquoiseMiddle
    static let tealLight = ColorTokens.bleuTurquoiseLight
    static let tealPastel = ColorTokens.bleuTurquoisePastel

    // Surfaces
    static let surfaceWhite = ColorTokens.blanc
    static let separator = ColorTokens.separatorLight
}
