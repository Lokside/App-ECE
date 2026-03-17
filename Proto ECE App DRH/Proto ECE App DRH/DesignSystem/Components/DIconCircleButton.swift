import SwiftUI

struct DIconCircleButton: View {
    let symbol: String
    let iconColor: Color
    let background: Color

    var body: some View {
        Circle()
            .fill(background)
            .frame(width: 36, height: 36)
            .shadow(color: ColorTokens.noir.opacity(0.3), radius: 1, x: 0, y: 0)
            .overlay {
                Image(systemName: symbol)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(iconColor)
            }
    }
}
