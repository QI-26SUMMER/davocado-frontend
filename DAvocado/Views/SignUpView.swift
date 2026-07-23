import SwiftUI

struct SignUpView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var nickname = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isSubmitting = false
    @State private var didSucceed = false

    private var canSubmit: Bool { !email.isEmpty && !password.isEmpty }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.avocadoCream.ignoresSafeArea()

                VStack(spacing: 14) {
                    if didSucceed {
                        Text("Account created — log in to continue.")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.avocadoGreen)
                            .padding(.top, 40)
                    } else {
                        field(label: "NICKNAME") {
                            TextField("Avocado Lover", text: $nickname)
                        }
                        field(label: "EMAIL") {
                            TextField("hello@example.com", text: $email)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                        }
                        field(label: "PASSWORD") {
                            SecureField("••••••••", text: $password)
                        }

                        if let message = appState.authErrorMessage {
                            Text(message)
                                .font(.system(size: 12))
                                .foregroundStyle(Color.avocadoRust)
                        }

                        Button {
                            Task {
                                isSubmitting = true
                                didSucceed = await appState.signUp(email: email, password: password, nickname: nickname)
                                isSubmitting = false
                            }
                        } label: {
                            Text(isSubmitting ? "SIGNING UP…" : "SIGN UP")
                                .font(.system(size: 14, weight: .bold))
                                .tracking(2.8)
                                .foregroundStyle(Color.avocadoCream)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.avocadoGreen, in: RoundedRectangle(cornerRadius: 20))
                        }
                        .disabled(!canSubmit || isSubmitting)
                        .opacity(canSubmit ? 1 : 0.6)
                        .padding(.top, 8)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 32)
            }
            .navigationTitle("Sign Up")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private func field(label: String, @ViewBuilder content: () -> some View) -> some View {
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
    SignUpView()
        .environment(AppState())
}
