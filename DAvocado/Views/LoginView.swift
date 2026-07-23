import SwiftUI

struct LoginView: View {
    @Environment(AppState.self) private var appState

    @State private var email = ""
    @State private var password = ""
    @State private var isSubmitting = false
    @State private var showSignUp = false

    private var canLogIn: Bool { !email.isEmpty && !password.isEmpty && !isSubmitting }

    var body: some View {
        ZStack {
            Color.avocadoCream.ignoresSafeArea()

            Image("AvocadoDecoTopRight")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 195)
                .opacity(0.07)
                .rotationEffect(.degrees(28))
                .position(x: 335, y: 50)

            Image("AvocadoDecoBottomLeft")
                .resizable()
                .scaledToFit()
                .frame(width: 110, height: 143)
                .opacity(0.06)
                .rotationEffect(.degrees(-20))
                .position(x: 25, y: 645)

            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 12) {
                    Image("AvocadoLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 52, height: 68)

                    VStack(alignment: .leading, spacing: 5) {
                        Text("AVOCADO RIPENESS")
                            .font(.system(size: 9, weight: .bold))
                            .tracking(3.4)
                            .foregroundStyle(Color.avocadoRust)
                        Text("D-avocado")
                            .font(.avocadoDisplay(38))
                            .foregroundStyle(Color.avocadoGreen)
                    }
                }
                .padding(.top, 56)
                .padding(.horizontal, 24)
                .padding(.bottom, 28)

                VStack(spacing: 14) {
                    avocadoField(label: "EMAIL") {
                        TextField("hello@example.com", text: $email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }

                    avocadoField(label: "PASSWORD") {
                        SecureField("••••••••", text: $password)
                    }

                    if let message = appState.authErrorMessage {
                        Text(message)
                            .font(.system(size: 12))
                            .foregroundStyle(Color.avocadoRust)
                            .padding(.top, 4)
                    }

                    Button {
                        Task {
                            isSubmitting = true
                            _ = await appState.logIn(email: email, password: password)
                            isSubmitting = false
                        }
                    } label: {
                        Text(isSubmitting ? "LOGGING IN…" : "LOG IN")
                            .font(.system(size: 14, weight: .bold))
                            .tracking(2.8)
                            .foregroundStyle(Color.avocadoCream)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.avocadoGreen, in: RoundedRectangle(cornerRadius: 20))
                    }
                    .disabled(!canLogIn)
                    .opacity(canLogIn ? 1 : 0.6)
                    .padding(.top, 15)

                    HStack(spacing: 12) {
                        Rectangle().fill(Color.avocadoBorder).frame(height: 1)
                        Text("OR")
                            .font(.system(size: 9, weight: .bold))
                            .tracking(2.7)
                            .foregroundStyle(Color.avocadoTextBrown)
                        Rectangle().fill(Color.avocadoBorder).frame(height: 1)
                    }
                    .padding(.top, 8)

                    Button {
                        showSignUp = true
                    } label: {
                        Text("New here? Sign Up")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.avocadoTextBrown)
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 24)

                Spacer()
            }
        }
        .sheet(isPresented: $showSignUp) {
            SignUpView()
        }
    }

    @ViewBuilder
    private func avocadoField(label: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 11, weight: .bold))
                .tracking(2.9)
                .foregroundStyle(Color.avocadoGreen)

            content()
                .font(.system(size: 14))
                .foregroundStyle(Color.avocadoTextBrown)
                .padding(.vertical, 13)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.avocadoCream)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.avocadoGreen, lineWidth: 1.7))
                )
        }
    }
}

#Preview {
    LoginView()
        .environment(AppState())
}
