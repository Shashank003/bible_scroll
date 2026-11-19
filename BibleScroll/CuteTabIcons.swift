import UIKit

/// Small vector drawings keep the tab icons crisp at every display scale.
enum CuteTabIcons {
    static let home = draw { context in
        // One continuous outline, with a simple rounded doorway.
        stroke(context, points: [CGPoint(x: 3, y: 14), CGPoint(x: 16, y: 3), CGPoint(x: 29, y: 14)])
        let walls = UIBezierPath()
        walls.move(to: CGPoint(x: 7, y: 12))
        walls.addLine(to: CGPoint(x: 7, y: 25))
        walls.addQuadCurve(to: CGPoint(x: 10, y: 28), controlPoint: CGPoint(x: 7, y: 28))
        walls.addLine(to: CGPoint(x: 22, y: 28))
        walls.addQuadCurve(to: CGPoint(x: 25, y: 25), controlPoint: CGPoint(x: 25, y: 28))
        walls.addLine(to: CGPoint(x: 25, y: 12))
        walls.lineWidth = 2
        walls.lineCapStyle = .round
        walls.stroke()
        let door = UIBezierPath(roundedRect: CGRect(x: 13, y: 18, width: 6, height: 10), cornerRadius: 2)
        door.lineWidth = 2
        door.stroke()
    }

    static let bible = draw { context in
        // Two gently curved pages with a small twinkle.
        let pages = UIBezierPath()
        pages.move(to: CGPoint(x: 16, y: 9))
        pages.addCurve(to: CGPoint(x: 4, y: 7), controlPoint1: CGPoint(x: 12, y: 6), controlPoint2: CGPoint(x: 8, y: 6))
        pages.addQuadCurve(to: CGPoint(x: 3, y: 10), controlPoint: CGPoint(x: 3, y: 7))
        pages.addLine(to: CGPoint(x: 3, y: 25))
        pages.addQuadCurve(to: CGPoint(x: 5, y: 27), controlPoint: CGPoint(x: 3, y: 27))
        pages.addQuadCurve(to: CGPoint(x: 16, y: 29), controlPoint: CGPoint(x: 12, y: 25))
        pages.addQuadCurve(to: CGPoint(x: 27, y: 27), controlPoint: CGPoint(x: 20, y: 25))
        pages.addQuadCurve(to: CGPoint(x: 29, y: 25), controlPoint: CGPoint(x: 29, y: 27))
        pages.addLine(to: CGPoint(x: 29, y: 12))
        pages.lineWidth = 2
        pages.lineCapStyle = .round
        pages.lineJoinStyle = .round
        pages.stroke()
        stroke(context, points: [CGPoint(x: 16, y: 9), CGPoint(x: 16, y: 29)])
        stroke(context, points: [CGPoint(x: 7, y: 17), CGPoint(x: 11, y: 17)])
        stroke(context, points: [CGPoint(x: 7, y: 21), CGPoint(x: 11, y: 21)])
        stroke(context, points: [CGPoint(x: 21, y: 18), CGPoint(x: 25, y: 18)])
        stroke(context, points: [CGPoint(x: 21, y: 22), CGPoint(x: 25, y: 22)])
        let star = UIBezierPath()
        star.move(to: CGPoint(x: 25, y: 2))
        star.addQuadCurve(to: CGPoint(x: 30, y: 7), controlPoint: CGPoint(x: 25, y: 7))
        star.addQuadCurve(to: CGPoint(x: 25, y: 12), controlPoint: CGPoint(x: 25, y: 7))
        star.addQuadCurve(to: CGPoint(x: 20, y: 7), controlPoint: CGPoint(x: 25, y: 7))
        star.addQuadCurve(to: CGPoint(x: 25, y: 2), controlPoint: CGPoint(x: 25, y: 7))
        star.fill()
    }

    private static func draw(_ drawing: (CGContext) -> Void) -> UIImage {
        UIGraphicsImageRenderer(size: CGSize(width: 32, height: 32)).image { renderer in
            UIColor.black.setStroke()
            UIColor.black.setFill()
            drawing(renderer.cgContext)
        }.withRenderingMode(.alwaysTemplate)
    }

    private static func stroke(_ context: CGContext, points: [CGPoint]) {
        guard let first = points.first else { return }
        context.setLineWidth(2)
        context.setLineCap(.round)
        context.setLineJoin(.round)
        context.beginPath()
        context.move(to: first)
        for point in points.dropFirst() { context.addLine(to: point) }
        context.strokePath()
    }

}
