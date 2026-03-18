import SwiftUI

// Design: 619:1100 – Log In 1
struct LoginScreen: View {
    @Environment(AppRouter.self)    private var router
    @Environment(AppContainer.self) private var container
    @State private var vm: AuthViewModel?

    var body: some View {
        ZStack {
            Color.scoonDark.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("scoon")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.top, 46)
                        .padding(.leading, 15)

                    Text("Einloggen")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                        .tracking(-0.3)
                        .padding(.top, 76)
                        .padding(.leading, 16)

                    if let vm {
                        VStack(spacing: 0) {
                            // Email
                            ScoonTextField(
                                label: "Email address",
                                placeholder: "Email address",
                                text: Binding(get: { vm.email }, set: { vm.email = $0 })
                            )
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding(.top, 28)

                            // Password
                            ScoonTextField(
                                label: "Password",
                                placeholder: "Passwort",
                                text: Binding(get: { vm.password }, set: { vm.password = $0 }),
                                isSecure: true
                            )
                            .padding(.top, 20)

                            // Forgot password
                            HStack {
                                Spacer()
                                Button(action: {}) {
                                    Text("Forgot password?")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color.scoonTextSecondary)
                                }
                            }
                            .padding(.top, 8)

                            // Error message
                            if let error = vm.error {
                                HStack(spacing: 8) {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .foregroundColor(.red)
                                    Text(error)
                                        .font(.system(size: 13))
                                        .foregroundColor(.red)
                                }
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(8)
                                .padding(.top, 12)
                            }

                            // Login button
                            Button(action: {
                                Task { await vm.login() }
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(vm.isLoginValid ? Color.scoonOrange : Color.scoonOrange.opacity(0.5))
                                    if vm.isLoading {
                                        ProgressView().tint(.white)
                                    } else {
                                        Text("Einloggen")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.white)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                            }
                            .disabled(vm.isLoading)
                            .padding(.top, 28)

                            // Divider
                            HStack {
                                Rectangle().fill(Color.scoonTextSecondary.opacity(0.4)).frame(height: 1)
                                Text("Or Login with")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.scoonTextSecondary)
                                    .fixedSize()
                                Rectangle().fill(Color.scoonTextSecondary.opacity(0.4)).frame(height: 1)
                            }
                            .padding(.top, 32)

                            // Social buttons
                            HStack(spacing: 16) {
                                SocialIconButton(systemImage: "f.square.fill", tint: Color(red: 0.23, green: 0.35, blue: 0.6)) {}
                                SocialIconButton(systemImage: "g.circle.fill", tint: Color(red: 0.92, green: 0.26, blue: 0.21)) {
                                    Task { await vm.signInWithGoogle() }
                                }
                                SocialIconButton(systemImage: "apple.logo", tint: .black) {}
                            }
                            .padding(.top, 20)
                        }
                        .padding(.horizontal, 16)
                        .onChange(of: vm.isSuccess) { _, success in
                            guard success else { return }
                            // Clear entire auth stack, land directly on Home
                            router.navigateToRoot()
                            router.navigate(to: .home)
                        }
                    }

                    // Register link
                    HStack(spacing: 4) {
                        Text("Noch kein Konto?")
                            .foregroundColor(.white.opacity(0.7))
                        Button(action: { router.navigate(to: .signUpSocial) }) {
                            Text("Registrieren")
                                .foregroundColor(Color.scoonOrange)
                                .underline()
                                .fontWeight(.semibold)
                        }
                    }
                    .font(.system(size: 14))
                    .frame(maxWidth: .infinity)
                    .padding(.top, 36)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            if vm == nil { vm = container.makeAuthViewModel() }
        }
    }
}

private struct SocialIconButton: View {
    let systemImage: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .resizable().scaledToFit()
                .frame(width: 22, height: 22)
                .foregroundColor(tint)
                .frame(maxWidth: .infinity)
                .frame(height: 57)
                .background(.white)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.scoonBorder, lineWidth: 1))
                .cornerRadius(10)
        }
    }
}
