import SwiftUI

struct LoginScreen: View {
    @Environment(AppRouter.self)    private var router
    @Environment(AppContainer.self) private var container
    @State private var vm: AuthViewModel?
    @State private var appeared   = false
    @State private var showReset  = false

    var body: some View {
        ZStack {
            Color.scoonDarker.ignoresSafeArea()

            // Subtle orange ambient at bottom
            RadialGradient(
                colors: [Color.scoonOrange.opacity(0.14), .clear],
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
                        Text("Willkommen zurück")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.primary)
                        Text("Melde dich an, um weiterzumachen.")
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
                            AuthField(label: "E-Mail-Adresse", placeholder: "name@beispiel.de",
                                      text: Binding(get: { vm.email }, set: { vm.email = $0 }),
                                      keyboard: .emailAddress)
                            AuthField(label: "Passwort", placeholder: "Dein Passwort",
                                      text: Binding(get: { vm.password }, set: { vm.password = $0 }),
                                      isSecure: true)
                        }
                        .padding(.top, 36)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 12)
                        .animation(.easeOut(duration: 0.4).delay(0.1), value: appeared)

                        // Forgot password
                        HStack {
                            Spacer()
                            Button(action: { showReset = true }) {
                                Text("Passwort vergessen?")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(Color.scoonOrange.opacity(0.8))
                            }
                        }
                        .padding(.top, 10)

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

                        // Login button
                        Button(action: { Task { await vm.login() } }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        vm.isLoginValid
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
                                    Text("Anmelden")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity).frame(height: 58)
                            .shadow(
                                color: vm.isLoginValid ? Color.scoonOrange.opacity(0.4) : .clear,
                                radius: 12, x: 0, y: 4
                            )
                        }
                        .disabled(!vm.isLoginValid || vm.isLoading)
                        .padding(.top, 24)

                        // Divider
                        HStack {
                            Rectangle().fill(Color.primary.opacity(0.1)).frame(height: 1)
                            Text("oder")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.3))
                                .padding(.horizontal, 14)
                            Rectangle().fill(Color.primary.opacity(0.1)).frame(height: 1)
                        }
                        .padding(.top, 24)

                        // Google
                        GoogleLoginButton(isLoading: vm.isLoading) {
                            Task { await vm.signInWithGoogle() }
                        }
                        .padding(.top, 14)

                        // Register link
                        HStack(spacing: 4) {
                            Text("Noch kein Konto?")
                                .foregroundColor(.white.opacity(0.4))
                            Button(action: { router.navigate(to: .signUpSocial) }) {
                                Text("Registrieren")
                                    .foregroundColor(Color.scoonOrange)
                                    .fontWeight(.semibold)
                            }
                        }
                        .font(.system(size: 14))
                        .frame(maxWidth: .infinity)
                        .padding(.top, 24)
                        .padding(.bottom, 48)
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
        .sheet(isPresented: $showReset, onDismiss: { vm?.clearResetState() }) {
            if let vm {
                PasswordResetSheet(vm: vm)
            }
        }
    }
}

// MARK: – Password Reset Sheet

private struct PasswordResetSheet: View {
    let vm: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.scoonDarker.ignoresSafeArea()

            RadialGradient(
                colors: [Color.scoonOrange.opacity(0.1), .clear],
                center: .top, startRadius: 0, endRadius: 250
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // Handle
                Capsule()
                    .fill(Color.white.opacity(0.18))
                    .frame(width: 36, height: 4)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 12)

                if vm.resetEmailSent {
                    // Success state
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(Color.scoonOrange.opacity(0.15))
                                .frame(width: 80, height: 80)
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(Color.scoonOrange)
                        }
                        VStack(spacing: 8) {
                            Text("E-Mail gesendet")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                            Text("Schau in dein Postfach. Der Reset-Link ist 1 Stunde gültig.")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.5))
                                .multilineTextAlignment(.center)
                        }
                        Button(action: { dismiss() }) {
                            Text("Schließen")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        colors: [Color.scoonOrange, Color(red: 1.0, green: 0.55, blue: 0.15)],
                                        startPoint: .leading, endPoint: .trailing
                                    )
                                    .cornerRadius(16)
                                )
                                .shadow(color: Color.scoonOrange.opacity(0.4), radius: 12, x: 0, y: 4)
                        }
                        .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 24)
                    .padding(.top, 40)
                } else {
                    // Input state
                    VStack(alignment: .leading, spacing: 6) {
                        Text("PASSWORT ZURÜCKSETZEN")
                            .font(.system(size: 11, weight: .semibold))
                            .tracking(1.5)
                            .foregroundColor(Color.scoonOrange.opacity(0.8))
                            .padding(.top, 28)
                        Text("Reset-Link anfordern")
                            .font(.system(size: 26, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        Text("Gib deine E-Mail ein und wir senden dir einen Link zum Zurücksetzen deines Passworts.")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.45))
                            .lineSpacing(3)
                            .padding(.top, 4)
                    }
                    .padding(.horizontal, 24)

                    // Email field
                    HStack(spacing: 10) {
                        Image(systemName: "envelope")
                            .font(.system(size: 15))
                            .foregroundColor(.white.opacity(0.35))
                        TextField(
                            "",
                            text: Binding(get: { vm.resetEmail }, set: { vm.resetEmail = $0 }),
                            prompt: Text("deine@email.de").foregroundColor(.white.opacity(0.3))
                        )
                        .font(.system(size: 15))
                        .foregroundColor(.white)
                        .tint(Color.scoonOrange)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 15)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.06)))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.1), lineWidth: 1))
                    .padding(.horizontal, 24)
                    .padding(.top, 24)

                    // Error
                    if let error = vm.error {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.circle.fill").foregroundColor(.red.opacity(0.8))
                            Text(error).font(.system(size: 13)).foregroundColor(.red.opacity(0.8))
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.red.opacity(0.2), lineWidth: 1))
                        .padding(.horizontal, 24)
                        .padding(.top, 10)
                    }

                    // Button
                    Button(action: { Task { await vm.resetPassword() } }) {
                        ZStack {
                            LinearGradient(
                                colors: [
                                    Color.scoonOrange.opacity(vm.resetEmail.contains("@") ? 1 : 0.35),
                                    Color(red: 1.0, green: 0.55, blue: 0.15).opacity(vm.resetEmail.contains("@") ? 1 : 0.35)
                                ],
                                startPoint: .leading, endPoint: .trailing
                            )
                            .cornerRadius(16)
                            if vm.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Reset-Link senden")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .shadow(
                            color: Color.scoonOrange.opacity(vm.resetEmail.contains("@") ? 0.4 : 0),
                            radius: 12, x: 0, y: 4
                        )
                    }
                    .disabled(!vm.resetEmail.contains("@") || vm.isLoading)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }

                Spacer()
            }
        }
        .presentationDetents([.height(380)])
        .presentationCornerRadius(28)
        .presentationBackground(Color.scoonDarker)
    }
}

private struct GoogleLoginButton: View {
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(.white).frame(width: 28, height: 28)
                    GoogleGMark()
                }
                Text("Mit Google anmelden")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                Spacer()
                if isLoading {
                    ProgressView().tint(.gray).scaleEffect(0.8)
                }
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity).frame(height: 56)
            .background(.white)
            .cornerRadius(14)
            .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 2)
        }
        .disabled(isLoading)
    }
}
