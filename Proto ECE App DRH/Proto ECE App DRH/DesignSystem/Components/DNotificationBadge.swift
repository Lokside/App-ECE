import SwiftUI

struct DNotificationBadge: View {
    let count: Int

    var body: some View {
        Text("\(count)")
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: 16, height: 16)
            .background(ColorTokens.corailMHBrand)
            .clipShape(Circle())
    }
}
