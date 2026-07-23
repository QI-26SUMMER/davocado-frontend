import SwiftUI

struct DayBadge: View {
    let daysToTarget: Double?
    let status: String?

    private var background: Color {
        switch status {
        case "eat_now": return .avocadoRust
        case "overripe": return .avocadoOverripeDark
        default: return Color("RipenessUnripe").opacity(0.55)
        }
    }

    private var foreground: Color {
        switch status {
        case "eat_now": return .avocadoCream
        case "overripe": return .white
        default: return .avocadoDarkText
        }
    }

    var body: some View {
        Text(formatDayCountdown(daysToTarget: daysToTarget, status: status).uppercased())
            .font(.system(size: 9, weight: .bold))
            .foregroundStyle(foreground)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(background, in: RoundedRectangle(cornerRadius: 3))
    }
}
