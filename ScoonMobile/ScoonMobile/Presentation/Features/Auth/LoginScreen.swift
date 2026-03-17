import SwiftUI

// Design: 619:1100 – Log In 1
// Dark theme: email + password, forgot password, primary button, social logins.
struct LoginScreen: View {
    @Environment(AppRouter.self) private var router

    @State private var email    = "patrick.hennes@scoon.at"
    @State private var password = "········"

    var body: some View {
        ZStack {
            Color.scoonDark.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Logo (top-left, small)
                    Text("scoon")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.top, 46)
                        .padding(.leading, 15)

                    // Heading
                    Text("Einloggen")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                        .tracking(-0.3)
                        .padding(.top, 76)
                        .padding(.leading, 16)

                    VStack(spacing: 0) {
                        // Email
                        ScoonTextField(
                            label: "Email address",
                            placeholder: "Email address",
                            text: $email
                        )
                        .keyboardType(.emailAddress)
                        .padding(.top, 28)

                        // Password
                        ScoonTextField(
                            label: "Password",
                            placeholder: "",
                            text: $password,
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

                        // Login button
                        Button(action: { router.navigate(to: .home) }) {
                            Text("Einloggen")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.scoonOrange)
                                .cornerRadius(10)
                        }
                        .padding(.top, 28)

                        // Divider "Or Login with"
                        HStack {
                            Rectangle()
                                .fill(Color.scoonTextSecondary.opacity(0.4))
                                .frame(height: 1)
                            Text("Or Login with")
                                .font(.system(size: 14))
                                .foregroundColor(Color.scoonTextSecondary)
                                .fixedSize()
                            Rectangle()
                                .fill(Color.scoonTextSecondary.opacity(0.4))
                                .frame(height: 1)
                        }
                        .padding(.top, 32)

                        // Social buttons
                        HStack(spacing: 16) {
                            SocialIconButton(systemImage: "f.square.fill",  tint: Color(red: 0.23, green: 0.35, blue: 0.6))
                            SocialIconButton(systemImage: "g.circle.fill",  tint: Color(red: 0.92, green: 0.26, blue: 0.21))
                            SocialIconButton(systemImage: "apple.logo",     tint: .black)
                        }
                        .padding(.top, 20)
                    }
                    .padding(.horizontal, 16)

                    // No account yet
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
    }
}

private struct SocialIconButton: View {
    let systemImage: String
    let tint: Color

    var body: some View {
        Button(action: {}) {
            Image(systemName: systemImage)
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22)
                .foregroundColor(tint)
                .frame(maxWidth: .infinity)
                .frame(height: 57)
                .background(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.scoonBorder, lineWidth: 1)
                )
                .cornerRadius(10)
        }
    }
}
