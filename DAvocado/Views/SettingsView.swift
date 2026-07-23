import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        ScrollView {
            ScreenHeader(title: "SETTINGS", subtitle: "Customize Your Preferences")

            profileCard
                .padding(.horizontal, 20)
                .padding(.bottom, 24)

            preferredRipenessSection(selection: preferredStageBinding)
                .padding(.horizontal, 20)
                .padding(.bottom, 24)

            notificationSection(
                pushEnabled: pushEnabledBinding,
                advanceNotice: advanceNoticeBinding
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 24)

            logOutButton
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
        }
        .background(Color.avocadoCream)
    }

    private var preferredStageBinding: Binding<RipenessStage> {
        Binding(
            get: { RipenessStage(rawValue: appState.preferredStage) ?? .justRight },
            set: { newValue in Task { await appState.updateSettings(preferredStage: newValue.rawValue) } }
        )
    }

    private var pushEnabledBinding: Binding<Bool> {
        Binding(
            get: { appState.pushEnabled },
            set: { newValue in Task { await appState.updateSettings(pushEnabled: newValue) } }
        )
    }

    private var advanceNoticeBinding: Binding<AdvanceNotice> {
        Binding(
            get: { AdvanceNotice(rawValue: appState.advanceNoticeDays) ?? .oneDayBefore },
            set: { newValue in Task { await appState.updateSettings(advanceNoticeDays: newValue.rawValue) } }
        )
    }

    private var profileCard: some View {
        Button {
            // TODO: profile detail screen
        } label: {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color("RipenessUnripe").opacity(0.7))
                    .frame(width: 44, height: 44)
                    .overlay(Image(systemName: "person.fill").foregroundStyle(Color.avocadoCream))

                VStack(alignment: .leading, spacing: 2) {
                    Text(appState.currentUser?.nickname?.isEmpty == false ? appState.currentUser!.nickname! : "Avocado Lover")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.avocadoCream)
                    Text(appState.currentUser?.email ?? "")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.avocadoCream.opacity(0.75))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.avocadoCream)
            }
            .padding(16)
            .background(Color.avocadoGreen, in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }

    private func preferredRipenessSection(selection: Binding<RipenessStage>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("PREFERRED RIPENESS")
                .font(.system(size: 12, weight: .bold))
                .tracking(2.9)
                .foregroundStyle(Color.avocadoTextBrown)
            Text("Select ripeness stage for notifications")
                .font(.system(size: 10))
                .foregroundStyle(Color.avocadoTextBrown)

            HStack(spacing: 6) {
                ForEach(RipenessStage.allCases) { stage in
                    ripenessButton(stage, selection: selection)
                }
            }
            .padding(.top, 12)

            HStack(spacing: 0) {
                ForEach(RipenessStage.allCases) { stage in
                    Rectangle().fill(stage.color)
                }
            }
            .frame(height: 8)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .padding(.top, 8)

            HStack {
                Text("Unripe")
                Spacer()
                Text("Overripe")
            }
            .font(.system(size: 8, weight: .bold))
            .foregroundStyle(Color.avocadoTextBrown)
            .padding(.top, 4)
        }
    }

    private func ripenessButton(_ stage: RipenessStage, selection: Binding<RipenessStage>) -> some View {
        let isSelected = selection.wrappedValue == stage
        return Button {
            selection.wrappedValue = stage
        } label: {
            VStack(spacing: 4) {
                Text("\(stage.rawValue)")
                    .font(.avocadoDisplay(20))
                    .foregroundStyle(isSelected ? .white : stage.color)
                Text(stage.label)
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(isSelected ? .white.opacity(0.9) : Color.avocadoTextBrown)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(isSelected ? stage.color : Color.avocadoCard, in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.avocadoDarkText : Color.avocadoBorder, lineWidth: 1.7)
            )
        }
        .buttonStyle(.plain)
    }

    private func notificationSection(pushEnabled: Binding<Bool>, advanceNotice: Binding<AdvanceNotice>) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("NOTIFICATION SETTINGS")
                .font(.system(size: 12, weight: .bold))
                .tracking(2.9)
                .foregroundStyle(Color.avocadoTextBrown)

            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Push Notifications")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.avocadoDarkText)
                        Text("Get notified when ripe")
                            .font(.system(size: 10))
                            .foregroundStyle(Color.avocadoTextBrown)
                    }
                    Spacer()
                    Toggle("", isOn: pushEnabled)
                        .labelsHidden()
                        .tint(Color.avocadoGreen)
                }
                .padding(16)

                Divider().background(Color.avocadoBorder)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Advance Notice")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.avocadoDarkText)

                    HStack(spacing: 6) {
                        ForEach(AdvanceNotice.allCases) { option in
                            advanceNoticeButton(option, selection: advanceNotice)
                        }
                    }
                }
                .padding(16)
            }
            .background(Color.avocadoCard, in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.avocadoBorder, lineWidth: 1.7))
        }
    }

    private func advanceNoticeButton(_ option: AdvanceNotice, selection: Binding<AdvanceNotice>) -> some View {
        let isSelected = selection.wrappedValue == option
        return Button {
            selection.wrappedValue = option
        } label: {
            Text(option.label)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(isSelected ? Color.avocadoCream : Color.avocadoGreen)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(isSelected ? Color.avocadoGreen : Color.clear, in: RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.avocadoGreen : Color.avocadoBorder, lineWidth: 1.7)
                )
        }
        .buttonStyle(.plain)
    }

    private var logOutButton: some View {
        Button(role: .destructive) {
            Task { await appState.logOut() }
        } label: {
            Text("Log Out")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.avocadoRust)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.avocadoRust, lineWidth: 1.7)
                )
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environment(AppState())
}
