import SwiftUI

struct DAffiliationRow: View {
    let icon: String
    let iconForeground: Color
    let iconBackground: Color
    let label: String
    let percentage: Double
    let percentageText: String
    let barColor: Color

    var body: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(iconBackground)
                .frame(width: 32, height: 32)
                .overlay {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(iconForeground)
                }

            VStack(spacing: 8) {
                HStack {
                    Text(label)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(ColorTokens.noir)
                    Spacer()
                    Text(percentageText)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(ColorTokens.noir)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.6))
                            .frame(height: 8)
                        Capsule()
                            .fill(barColor)
                            .frame(width: geo.size.width * percentage, height: 8)
                    }
                }
                .frame(height: 8)
            }
        }
    }
}
