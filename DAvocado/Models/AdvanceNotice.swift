import Foundation

/// Settings "Advance Notice" — maps to `advance_notice_days` (0-3) in the API/DB spec.
enum AdvanceNotice: Int, CaseIterable, Identifiable {
    case sameDay = 0
    case oneDayBefore = 1
    case twoDaysBefore = 2
    case threeDaysBefore = 3

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .sameDay: return "Same Day"
        case .oneDayBefore: return "1 Day Before"
        case .twoDaysBefore: return "2 Days Before"
        case .threeDaysBefore: return "3 Days Before"
        }
    }
}
