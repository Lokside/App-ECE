import SwiftUI

struct DArretsDonutChart: View {
    let lineWidth: CGFloat
    let maladieAngle: Double
    let accidentAngle: Double
    let otherAngle: Double

    init(segments: ArretSegments? = nil, lineWidth: CGFloat = 15) {
        self.lineWidth = lineWidth
        self.maladieAngle = segments?.maladieAngle ?? 180
        self.accidentAngle = segments?.accidentAngle ?? 120
        self.otherAngle = segments?.otherAngle ?? 30
    }

    var body: some View {
        let maladieStart: Double = 5
        let accidentStart = maladieStart + maladieAngle + 10
        let otherStart = accidentStart + accidentAngle + 10

        ZStack {
            Circle()
                .stroke(Color(hex: 0xEEEEEE), lineWidth: lineWidth)

            if maladieAngle > 0 {
                Circle()
                    .trim(from: 0, to: maladieAngle / 360.0)
                    .stroke(ColorTokens.corailMHBrand, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .rotationEffect(.degrees(maladieStart - 90))
            }

            if accidentAngle > 0 {
                Circle()
                    .trim(from: 0, to: accidentAngle / 360.0)
                    .stroke(ColorTokens.bleuTurquoiseDark, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .rotationEffect(.degrees(accidentStart - 90))
            }

            if otherAngle > 0 {
                Circle()
                    .trim(from: 0, to: otherAngle / 360.0)
                    .stroke(ColorTokens.bleuTurquoiseLight, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .rotationEffect(.degrees(otherStart - 90))
            }
        }
    }
}
