import SwiftUI

extension Font {
    /// Stand-in for the brand's condensed display face (Anton), which isn't
    /// bundled in the app. Uses the system font at a heavy weight instead.
    static func avocadoDisplay(_ size: CGFloat) -> Font {
        .system(size: size, weight: .black, design: .default)
    }
}
