import SwiftUI

/// Four L-shaped corner marks framing a capture target, like a camera viewfinder.
struct CornerBracketsOverlay: Shape {
    var cornerLength: CGFloat = 20

    func path(in rect: CGRect) -> Path {
        var path = Path()

        func addCorner(at corner: CGPoint, dx: CGFloat, dy: CGFloat) {
            path.move(to: CGPoint(x: corner.x, y: corner.y + dy * cornerLength))
            path.addLine(to: corner)
            path.addLine(to: CGPoint(x: corner.x + dx * cornerLength, y: corner.y))
        }

        addCorner(at: CGPoint(x: rect.minX, y: rect.minY), dx: 1, dy: 1)
        addCorner(at: CGPoint(x: rect.maxX, y: rect.minY), dx: -1, dy: 1)
        addCorner(at: CGPoint(x: rect.minX, y: rect.maxY), dx: 1, dy: -1)
        addCorner(at: CGPoint(x: rect.maxX, y: rect.maxY), dx: -1, dy: -1)

        return path
    }
}

#Preview {
    CornerBracketsOverlay()
        .stroke(Color.avocadoGreen, lineWidth: 1.7)
        .frame(width: 100, height: 86)
        .padding()
        .background(Color.avocadoCream)
}
