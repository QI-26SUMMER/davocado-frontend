import SwiftUI

struct ScreenHeader<Trailing: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder var trailing: Trailing

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.avocadoDisplay(34))
                    .foregroundStyle(Color.avocadoGreen)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.avocadoTextBrown)
                    .padding(.top, 4)
            }
            Spacer()
            trailing
        }
        .padding(.horizontal, 20)
        .padding(.top, 48)
        .padding(.bottom, 16)
    }
}

extension ScreenHeader where Trailing == EmptyView {
    init(title: String, subtitle: String) {
        self.title = title
        self.subtitle = subtitle
        self.trailing = EmptyView()
    }
}

#Preview {
    ScreenHeader(title: "SCAN", subtitle: "We'll analyze your avocado photo")
        .background(Color.avocadoCream)
}
