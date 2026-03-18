import SwiftUI

struct LoginScreen: View {
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
                        Text("Willkommen zurück")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 28)

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

                        // Forgot password
                        HStack {
                            Spacer()
                            Button(action: {}) {
                                Text("Passwort vergessen?")
                                    .font(.system(size: 13))
                                    .foregroundColor(.white.opacity(0.4))
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
                            .cornerRadius(10)
                            .padding(.top, 12)
                        }

                        // Login button
                        Button(action: { Task { await vm.login() } }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(vm.isLoginValid ? Color.scoonOrange : Color.scoonOrange.opacity(0.4))
                                if vm.isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Anmelden")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity).frame(height: 56)
                        }
                        .disabled(!vm.isLoginValid || vm.isLoading)
                        .padding(.top, 24)

                        // Divider
                        HStack {
                            Rectangle().fill(Color.white.opacity(0.1)).frame(height: 1)
                            Text("oder")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.35))
                                .padding(.horizontal, 14)
                            Rectangle().fill(Color.white.opacity(0.1)).frame(height: 1)
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
                                .foregroundColor(.white.opacity(0.45))
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
        .navigationBarHidden(true)
        .onAppear { if vm == nil { vm = container.makeAuthViewModel() } }
        .onChange(of: vm?.isSuccess) { _, success in
            guard success == true else { return }
            router.navigateToRoot()
            router.navigate(to: .home)
        }
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
            .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 2)
        }
        .disabled(isLoading)
    }
}
