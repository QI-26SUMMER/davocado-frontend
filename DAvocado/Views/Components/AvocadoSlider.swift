import SwiftUI

/// Custom capsule-track slider matching the brand look (Settings > Room Temperature).
/// Built by hand rather than styling the system `Slider` because the design's thick
/// filled-capsule track + large circular thumb diverges enough from the system control
/// that restyling it would fight the defaults more than it would save.
struct AvocadoSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>

    private let trackHeight: CGFloat = 12
    private let thumbSize: CGFloat = 24

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let fraction = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
            let fillWidth = max(thumbSize / 2, min(width - thumbSize / 2, width * fraction))

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.avocadoCard)
                    .frame(height: trackHeight)

                Capsule()
                    .fill(Color("RipenessJustRight"))
                    .frame(width: fillWidth, height: trackHeight)

                Circle()
                    .fill(Color.avocadoGreen)
                    .frame(width: thumbSize, height: thumbSize)
                    .offset(x: fillWidth - thumbSize / 2)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0).onChanged { drag in
                    let clampedX = min(max(drag.location.x, 0), width)
                    let newFraction = clampedX / width
                    value = range.lowerBound + newFraction * (range.upperBound - range.lowerBound)
                }
            )
        }
        .frame(height: thumbSize)
    }
}

#Preview {
    @Previewable @State var value: Double = 24
    return AvocadoSlider(value: $value, range: 10...25)
        .padding()
        .background(Color.avocadoCream)
}
