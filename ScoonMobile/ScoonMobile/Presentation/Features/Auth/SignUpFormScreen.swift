import SwiftUI

/// Registrierung per E-Mail – vollständig mit AuthViewModel verdrahtet
struct SignUpFormScreen: View {
    @Environment(AppRouter.self)    private var router
    @Environment(AppContainer.self) private var container
    @State private var vm: AuthViewModel?

    var body: some View {
        ZStack {
            Color.scoonDark.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // Back
                    Button(action: { router.navigateBack() }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }
                    .padding(.top, 52)

                    // Headline
                    VStack(alignment: .leading, spacing: 6) {
                        Text("scoon")
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundColor(Color.scoonOrange)
                        Text("Konto erstellen")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 28)

                    if let vm {
                        VStack(spacing: 16) {
                            // Benutzername
                            AuthField(label: "Benutzername", placeholder: "dein_benutzername",
                                      text: Binding(get: { vm.username }, set: { vm.username = $0 }),
                                      keyboard: .default)

                            // E-Mail
                            AuthField(label: "E-Mail-Adresse", placeholder: "name@beispiel.de",
                                      text: Binding(get: { vm.email }, set: { vm.email = $0 }),
                                      keyboard: .emailAddress)

                            // Passwort
                            AuthField(label: "Passwort", placeholder: "Mind. 8 Zeichen",
                                      text: Binding(get: { vm.password }, set: { vm.password = $0 }),
                                      keyboard: .default, isSecure: true)
                        }
                        .padding(.top, 36)

                        // Error
                        if let error = vm.error {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.circle.fill").foregroundColor(.red)
                                Text(error).font(.system(size: 13)).foregroundColor(.red)
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(10)
                            .padding(.top, 12)
                        }

                        // Submit
                        Button(action: { Task { await vm.signUp() } }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(vm.isSignUpValid ? Color.scoonOrange : Color.scoonOrange.opacity(0.4))
                                if vm.isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Konto erstellen")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity).frame(height: 56)
                        }
                        .disabled(!vm.isSignUpValid || vm.isLoading)
                        .padding(.top, 28)

                        // Terms
                        Text("Mit der Registrierung stimmst du unseren Nutzungsbedingungen und der Datenschutzerklärung zu.")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.35))
                            .multilineTextAlignment(.center)
                            .padding(.top, 16)

                        // Login link
                        HStack(spacing: 4) {
                            Text("Bereits ein Konto?")
                                .foregroundColor(.white.opacity(0.45))
                            Button(action: { router.navigate(to: .login) }) {
                                Text("Anmelden")
                                    .foregroundColor(Color.scoonOrange)
                                    .fontWeight(.semibold)
                            }
                        }
                        .font(.system(size: 14))
                        .frame(maxWidth: .infinity)
                        .padding(.top, 20)
                        .padding(.bottom, 48)

                        // Navigation on success
                        let _ = vm.isSuccess  // observe
                    }
                }
                .padding(.horizontal, 24)
            }
        }
        .navigationBarHidden(true)
        .onAppear { if vm == nil { vm = container.makeAuthViewModel() } }
        .onChange(of: vm?.isSuccess) { _, success in
            guard success == true else { return }
            router.navigateToRoot()
            router.navigate(to: .home)
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
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.5))
                .textCase(.uppercase)
                .tracking(0.8)

            Group {
                if isSecure {
                    SecureField("", text: $text, prompt:
                        Text(placeholder).foregroundColor(.white.opacity(0.45)))
                } else {
                    TextField("", text: $text, prompt:
                        Text(placeholder).foregroundColor(.white.opacity(0.45)))
                        .keyboardType(keyboard)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                }
            }
            .font(.system(size: 16))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .frame(height: 52)
            .background(Color.white.opacity(0.08))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
        }
    }
}
