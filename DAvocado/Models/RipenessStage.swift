import SwiftUI

enum RipenessStage: Int, CaseIterable, Identifiable {
    case veryUnripe = 1
    case unripe = 2
    case justRight = 3
    case ripe = 4
    case overripe = 5

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .veryUnripe: return "Very Unripe"
        case .unripe: return "Unripe"
        case .justRight: return "Just Right"
        case .ripe: return "Ripe"
        case .overripe: return "Overripe"
        }
    }

    var color: Color {
        switch self {
        case .veryUnripe: return Color("RipenessVeryUnripe")
        case .unripe: return Color("RipenessUnripe")
        case .justRight: return Color("RipenessJustRight")
        case .ripe: return Color("RipenessRipe")
        case .overripe: return Color("RipenessOverripe")
        }
    }
}
