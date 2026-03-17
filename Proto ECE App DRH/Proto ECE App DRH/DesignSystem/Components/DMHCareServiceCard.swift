import SwiftUI

struct DMHCareServiceCard: View {
    let title: String
    let description: String
    let backgroundColor: Color
    let blobColor: Color
    let imageURL: String?

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .minimumScaleFactor(0.4)
                    .lineLimit(2)
                    .foregroundStyle(ColorTokens.noir)

                Text(description)
                    .font(.system(size: 12, weight: .regular))
                    .minimumScaleFactor(0.4)
                    .lineLimit(3)
                    .foregroundStyle(ColorTokens.noir)
            }
            .padding(.leading, 16)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)

            ZStack {
                OrganicBlob()
                    .fill(blobColor)
                    .frame(width: 120, height: 145)
                    .offset(x: 18, y: 12)

                if let imageURL {
                    DRemoteAssetImage(urlString: imageURL)
                        .scaledToFill()
                        .frame(width: 140, height: 140)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .offset(x: 14, y: 22)
                }
            }
            .frame(width: 98, height: 120)
            .clipped()
        }
        .frame(width: 272, height: 120)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(backgroundColor)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: ColorTokens.noir.opacity(0.3), radius: 4, x: 0, y: 1)
    }
}
