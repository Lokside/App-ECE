import SwiftUI

enum TypographyTokens {
    // Titres
    static let headline = Font.system(size: 24, weight: .bold, design: .rounded)
    static let title    = Font.system(size: 19, weight: .bold, design: .rounded)
    static let subtitle = Font.system(size: 18, weight: .bold, design: .rounded)

    // Corps
    static let body     = Font.system(size: 15, weight: .regular, design: .rounded)
    static let bodyBold = Font.system(size: 15, weight: .semibold, design: .rounded)
    static let caption  = Font.system(size: 14, weight: .regular, design: .rounded)
    static let small    = Font.system(size: 13, weight: .regular, design: .rounded)
    static let smallBold = Font.system(size: 13, weight: .semibold, design: .rounded)

    // Métriques
    static let metric   = Font.system(size: 22, weight: .bold, design: .rounded)
    static let metricSmall = Font.system(size: 16, weight: .bold, design: .rounded)

    // Badges & eyebrows
    static let badge    = Font.system(size: 11, weight: .semibold, design: .rounded)
    static let eyebrow  = Font.system(size: 11, weight: .semibold, design: .rounded)

    // Dates
    static let date     = Font.system(size: 12, weight: .regular, design: .rounded)
}
