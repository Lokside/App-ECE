import SwiftUI

struct DQuestionBar: View {
    let isOverDarkBackground: Bool

    private var adaptiveColor: Color {
        isOverDarkBackground ? .white : ColorTokens.noir
    }

    var body: some View {
        HStack(spacing: 4) {
            Button {} label: {
                Circle()
                    .stroke(adaptiveColor, lineWidth: 1)
                    .frame(width: 40, height: 40)
                    .overlay {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(adaptiveColor)
                    }
            }
            .buttonStyle(.plain)

            HStack(spacing: 8) {
                Text("Ma question")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(adaptiveColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 16)

                Button {} label: {
                    Circle()
                        .fill(.white)
                        .frame(width: 40, height: 40)
                        .overlay {
                            Image(systemName: "mic")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(ColorTokens.noir)
                        }
                }
                .buttonStyle(.plain)
            }
            .padding(.trailing, 4)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .stroke(.white, lineWidth: 1)
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                Capsule()
                    .fill(.ultraThinMaterial)

                Capsule()
                    .fill(Color.white.opacity(0.1))

                Capsule()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.6),
                                Color.white.opacity(0.2),
                                Color.white.opacity(0.4)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
        .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: 2)
        .shadow(color: Color(white: 0.18).opacity(0.25), radius: 5, x: 0, y: 3)
    }
}
