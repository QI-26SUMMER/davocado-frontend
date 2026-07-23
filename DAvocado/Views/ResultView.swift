import SwiftUI

struct ResultView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    private var result: ScanResponse {
        appState.lastScan ?? ResultView.placeholder
    }

    private static let placeholder = ScanResponse(
        id: 0,
        predictedStage: 2,
        confidence: nil,
        stageProbs: nil,
        targetStage: 3,
        daysToTarget: 3,
        estimatedPeakDate: nil,
        modelVersion: "unknown",
        image: nil,
        createdAt: .now,
        display: ScanDisplay(ddayText: "D-3", status: "ripening")
    )

    private var stage: RipenessStage? { RipenessStage(rawValue: result.predictedStage) }
    private var stageColor: Color { stage?.color ?? .avocadoGreen }

    private var optimalWindowDays: Double { 5 }
    private var progressFraction: Double {
        let days = result.daysToTarget ?? 0
        return min(max((optimalWindowDays - days) / optimalWindowDays, 0), 1)
    }

    private var subtitle: String {
        switch result.display?.status {
        case "eat_now": return "Perfect to eat now"
        case "overripe": return "Best used in a recipe today"
        default:
            let days = Int(result.daysToTarget?.rounded() ?? 0)
            return "Best to eat in \(days) days"
        }
    }

    var body: some View {
        ScrollView {
            header
            ripenessCard
                .padding(.horizontal, 20)
                .padding(.bottom, 16)

            untilOptimalCard
                .padding(.horizontal, 20)
                .padding(.bottom, 16)

            scaleStrip
                .padding(.horizontal, 20)
                .padding(.bottom, 32)

            rescanButton
                .padding(.bottom, 32)
        }
        .background(Color.avocadoCream)
        .navigationBarBackButtonHidden(true)
    }

    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.avocadoGreen)
            }
            Text("RESULT")
                .font(.avocadoDisplay(34))
                .foregroundStyle(Color.avocadoGreen)
            Spacer()
            Image(systemName: "bell")
                .font(.system(size: 20))
                .foregroundStyle(Color.avocadoGreen)
        }
        .padding(.horizontal, 20)
        .padding(.top, 48)
        .padding(.bottom, 16)
    }

    private var ripenessCard: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 12)
                .fill(stageColor)

            Image("AvocadoResultDeco")
                .resizable()
                .scaledToFit()
                .frame(width: 160, height: 208)
                .opacity(0.18)
                .frame(maxWidth: .infinity, alignment: .trailing)

            VStack(alignment: .leading, spacing: 4) {
                Text("RIPENESS STAGE")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(2.9)
                    .foregroundStyle(.white.opacity(0.75))

                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text("\(result.predictedStage)")
                        .font(.avocadoDisplay(90))
                        .foregroundStyle(.white)
                    Text("/ 5")
                        .font(.avocadoDisplay(36))
                        .foregroundStyle(.white.opacity(0.45))
                }

                Text(stage?.label ?? "Unknown")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
            }
            .padding(24)
        }
        .frame(height: 193)
    }

    private var untilOptimalCard: some View {
        VStack(spacing: 4) {
            Text("UNTIL OPTIMAL")
                .font(.system(size: 9, weight: .bold))
                .tracking(2.9)
                .foregroundStyle(Color.avocadoGreen)

            Text(result.display?.ddayText ?? "—")
                .font(.avocadoDisplay((result.display?.ddayText.count ?? 0) > 4 ? 40 : 74))
                .foregroundStyle(Color.avocadoGreen)

            Text(subtitle)
                .font(.system(size: 14))
                .foregroundStyle(Color.avocadoTextBrown)

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.avocadoTrack)
                    .frame(height: 12)
                GeometryReader { proxy in
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color("RipenessUnripe"))
                        .frame(width: proxy.size.width * progressFraction, height: 12)
                }
                .frame(height: 12)
            }
            .padding(.top, 16)

            HStack {
                Text("Purchase")
                Spacer()
                Text("Optimal")
            }
            .font(.system(size: 9))
            .foregroundStyle(Color.avocadoTextBrown)
            .padding(.top, 4)
        }
        .padding(24)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.avocadoGreen, lineWidth: 3.9)
        )
    }

    private var scaleStrip: some View {
        VStack(spacing: 4) {
            HStack(spacing: 0) {
                ForEach(RipenessStage.allCases) { stage in
                    Text("\(stage.rawValue)")
                        .font(.avocadoDisplay(12))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 28)
                        .background(stage.color.opacity(stage.rawValue == result.predictedStage ? 1 : 0.3))
                }
            }
            HStack {
                Text("Unripe")
                Spacer()
                Text("Overripe")
            }
            .font(.system(size: 8))
            .foregroundStyle(Color.avocadoTextBrown)
        }
    }

    private var rescanButton: some View {
        Button {
            dismiss()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "arrow.triangle.2.circlepath.camera")
                Text("Re-scan")
            }
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(Color.avocadoCream)
            .padding(.vertical, 12)
            .padding(.horizontal, 24)
            .background(Color.avocadoRust, in: RoundedRectangle(cornerRadius: 16))
        }
    }
}

#Preview {
    NavigationStack {
        ResultView()
    }
    .environment(AppState())
}
