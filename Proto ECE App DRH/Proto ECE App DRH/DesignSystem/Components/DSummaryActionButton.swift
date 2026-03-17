import SwiftUI

struct DSummaryActionButton: View {
    let icon: String
    let title: String

    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(ColorTokens.bleuTurquoiseDark)
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white)
                }

            Text(title)
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(ColorTokens.bleuTurquoiseDark)
                .multilineTextAlignment(.center)
                .lineSpacing(1)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: 115)
    }
}
