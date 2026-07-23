import SwiftUI

struct DayBadge: View {
    let display: ScanDisplay?

    private var background: Color {
        switch display?.status {
        case "eat_now": return .avocadoRust
        case "overripe": return .avocadoOverripeDark
        default: return Color("RipenessUnripe").opacity(0.55)
        }
    }

    private var foreground: Color {
        switch display?.status {
        case "eat_now": return .avocadoCream
        case "overripe": return .white
        default: return .avocadoDarkText
        }
    }

    var body: some View {
        Text((display?.ddayText ?? "—").uppercased())
            .font(.system(size: 9, weight: .bold))
            .foregroundStyle(foreground)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(background, in: RoundedRectangle(cornerRadius: 3))
    }
}
