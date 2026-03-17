import SwiftUI

// Design: 619:856 – Sign Up 3
// Dark theme: username / email / password, terms checkbox, submit button.
struct SignUpFormScreen: View {
    @Environment(AppRouter.self) private var router

    @State private var username = ""
    @State private var email    = ""
    @State private var password = ""
    @State private var accepted = true

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
                    Text("Account erstellen")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                        .tracking(-0.3)
                        .padding(.top, 60)
                        .padding(.leading, 22)

                    VStack(spacing: 0) {
                        // Username
                        ScoonTextField(label: "Username", placeholder: "Your username", text: $username)
                            .padding(.top, 32)

                        // Email
                        ScoonTextField(label: "Email", placeholder: "Your email", text: $email)
                            .keyboardType(.emailAddress)
                            .padding(.top, 20)

                        // Password
                        ScoonTextField(label: "Password", placeholder: "", text: $password, isSecure: true)
                            .padding(.top, 20)
                    }
                    .padding(.horizontal, 15)

                    // Terms checkbox
                    HStack(spacing: 10) {
                        Button(action: { accepted.toggle() }) {
                            Image(systemName: accepted ? "checkmark.circle.fill" : "circle")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(accepted ? Color.scoonOrange : .white.opacity(0.5))
                        }
                        Text("I accept the terms and privacy policy")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 28)
                    .padding(.horizontal, 15)

                    // Submit button
                    Button(action: {
                        router.navigate(to: .home)
                    }) {
                        Text("Account erstellen")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color.scoonDark)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 15)
                    .padding(.top, 28)

                    // Already have an account link
                    HStack(spacing: 4) {
                        Text("Bereits ein Konto?")
                            .foregroundColor(.white.opacity(0.7))
                        Button(action: { router.navigate(to: .login) }) {
                            Text("Jetzt anmelden!")
                                .foregroundColor(Color.scoonOrange)
                                .underline()
                                .fontWeight(.semibold)
                        }
                    }
                    .font(.system(size: 14))
                    .frame(maxWidth: .infinity)
                    .padding(.top, 28)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
    }
}
