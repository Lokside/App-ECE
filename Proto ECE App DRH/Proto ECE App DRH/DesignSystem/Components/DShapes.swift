import SwiftUI

struct OrganicBlob: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height
        path.move(to: CGPoint(x: w * 0.5, y: 0))
        path.addCurve(to: CGPoint(x: w, y: h * 0.4), control1: CGPoint(x: w * 0.8, y: 0), control2: CGPoint(x: w, y: h * 0.15))
        path.addCurve(to: CGPoint(x: w * 0.6, y: h), control1: CGPoint(x: w, y: h * 0.72), control2: CGPoint(x: w * 0.84, y: h))
        path.addCurve(to: CGPoint(x: 0, y: h * 0.6), control1: CGPoint(x: w * 0.32, y: h), control2: CGPoint(x: 0, y: h * 0.87))
        path.addCurve(to: CGPoint(x: w * 0.5, y: 0), control1: CGPoint(x: 0, y: h * 0.32), control2: CGPoint(x: w * 0.2, y: 0))
        path.closeSubpath()
        return path
    }
}

struct TopRoundedRectangle: Shape {
    let radius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: radius))
        path.addQuadCurve(
            to: CGPoint(x: radius, y: 0),
            control: CGPoint(x: 0, y: 0)
        )
        path.addLine(to: CGPoint(x: rect.width - radius, y: 0))
        path.addQuadCurve(
            to: CGPoint(x: rect.width, y: radius),
            control: CGPoint(x: rect.width, y: 0)
        )
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        return path
    }
}
