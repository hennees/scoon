import SwiftUI

struct SignUpFormScreen: View {
    @Environment(AppRouter.self)    private var router
    @Environment(AppContainer.self) private var container
    @State private var vm: AuthViewModel?
    @State private var appeared = false

    var body: some View {
        ZStack {
            Color.scoonDarker.ignoresSafeArea()

            RadialGradient(
                colors: [Color.scoonOrange.opacity(0.12), .clear],
                center: .init(x: 0.5, y: 1.1),
                startRadius: 0,
                endRadius: UIScreen.main.bounds.height * 0.5
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // ── Back ──────────────────────────────────────────
                    BackButton { router.navigateBack() }
                    .padding(.top, 56)
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeOut(duration: 0.3), value: appeared)

                    // ── Headline ──────────────────────────────────────
                    VStack(alignment: .leading, spacing: 6) {
                        Text("scoon")
                            .font(.system(size: 14, weight: .black, design: .rounded))
                            .foregroundColor(Color.scoonOrange)
                            .tracking(1)
                        Text("Konto erstellen")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.primary)
                        Text("Trete der Community bei.")
                            .font(.system(size: 15))
                            .foregroundColor(Color.scoonTextSecondary)
                            .padding(.top, 2)
                    }
                    .padding(.top, 28)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)
                    .animation(.easeOut(duration: 0.4).delay(0.05), value: appeared)

                    if let vm {
                        VStack(spacing: 16) {
                            AuthField(label: "Benutzername", placeholder: "dein_benutzername",
                                      text: Binding(get: { vm.username }, set: { vm.username = $0 }),
                                      keyboard: .default)
                            AuthField(label: "E-Mail-Adresse", placeholder: "name@beispiel.de",
                                      text: Binding(get: { vm.email }, set: { vm.email = $0 }),
                                      keyboard: .emailAddress)
                            AuthField(label: "Passwort", placeholder: "Mind. 8 Zeichen",
                                      text: Binding(get: { vm.password }, set: { vm.password = $0 }),
                                      keyboard: .default, isSecure: true)
                        }
                        .padding(.top, 36)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 12)
                        .animation(.easeOut(duration: 0.4).delay(0.1), value: appeared)

                        // Error
                        if let error = vm.error {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.circle.fill").foregroundColor(.red)
                                Text(error).font(.system(size: 13)).foregroundColor(.red)
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.red.opacity(0.2), lineWidth: 1))
                            .padding(.top, 12)
                        }

                        // Submit
                        Button(action: { Task { await vm.signUp() } }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        vm.isSignUpValid
                                        ? LinearGradient(
                                            colors: [Color.scoonOrange, Color(red: 1, green: 0.45, blue: 0.1)],
                                            startPoint: .leading, endPoint: .trailing)
                                        : LinearGradient(
                                            colors: [Color.scoonOrange.opacity(0.35), Color.scoonOrange.opacity(0.35)],
                                            startPoint: .leading, endPoint: .trailing)
                                    )
                                if vm.isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Konto erstellen")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity).frame(height: 58)
                            .shadow(
                                color: vm.isSignUpValid ? Color.scoonOrange.opacity(0.4) : .clear,
                                radius: 12, x: 0, y: 4
                            )
                        }
                        .disabled(!vm.isSignUpValid || vm.isLoading)
                        .padding(.top, 28)

                        // Terms
                        Text("Mit der Registrierung stimmst du unseren Nutzungsbedingungen und der Datenschutzerklärung zu.")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.3))
                            .multilineTextAlignment(.center)
                            .padding(.top, 14)

                        // Login link
                        HStack(spacing: 4) {
                            Text("Bereits ein Konto?")
                                .foregroundColor(.white.opacity(0.4))
                            Button(action: { router.navigate(to: .login) }) {
                                Text("Anmelden")
                                    .foregroundColor(Color.scoonOrange)
                                    .fontWeight(.semibold)
                            }
                        }
                        .font(.system(size: 14))
                        .frame(maxWidth: .infinity)
                        .padding(.top, 18)
                        .padding(.bottom, 48)

                        let _ = vm.isSuccess
                    }
                }
                .padding(.horizontal, 24)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            if vm == nil { vm = container.makeAuthViewModel() }
            appeared = true
        }
        .onChange(of: vm?.isSuccess) { _, success in
            guard success == true else { return }
            router.login()
        }
    }
}

// MARK: – Shared Auth TextField

struct AuthField: View {
    let label:       String
    let placeholder: String
    @Binding var text: String
    var keyboard:    UIKeyboardType = .default
    var isSecure:    Bool           = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color.scoonTextSecondary.opacity(0.8))
                .textCase(.uppercase)
                .tracking(1.0)

            Group {
                if isSecure {
                    SecureField("", text: $text, prompt:
                        Text(placeholder).foregroundColor(.white.opacity(0.35)))
                } else {
                    TextField("", text: $text, prompt:
                        Text(placeholder).foregroundColor(.white.opacity(0.35)))
                        .keyboardType(keyboard)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                }
            }
            .font(.system(size: 16))
            .foregroundColor(.primary)
            .padding(.horizontal, 16)
            .frame(height: 54)
            .background(Color.primary.opacity(0.07))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        text.isEmpty ? Color.primary.opacity(0.1) : Color.scoonOrange.opacity(0.4),
                        lineWidth: 1
                    )
            )
        }
    }
}
