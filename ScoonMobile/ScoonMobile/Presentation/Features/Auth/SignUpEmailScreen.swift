import SwiftUI

// Design: 619:900 – Sign Up 2
// Light card with email / password / confirm, "Create account" orange button.
struct SignUpEmailScreen: View {
    @Environment(AppRouter.self) private var router

    @State private var email    = ""
    @State private var password = ""
    @State private var confirm  = ""

    var body: some View {
        ZStack {
            Color.scoonDark.ignoresSafeArea()

            VStack(spacing: 0) {
                // Light card
                ZStack(alignment: .top) {
                    RoundedRectangle(cornerRadius: 32)
                        .fill(Color.scoonCardLight)

                    VStack(spacing: 0) {
                        Spacer().frame(height: 90)

                        // Logo
                        Text("scoon")
                            .font(.system(size: 72, weight: .black, design: .rounded))
                            .foregroundColor(.black)

                        Spacer().frame(height: 32)

                        // Heading
                        Text("Account erstellen")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.black)
                            .tracking(-0.3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)

                        Spacer().frame(height: 28)

                        // Email
                        ScoonTextField(
                            label: "",
                            placeholder: "Email address",
                            text: $email,
                            isDark: false
                        )
                        .keyboardType(.emailAddress)
                        .padding(.horizontal, 20)

                        Spacer().frame(height: 16)

                        // Password
                        ScoonTextField(
                            label: "",
                            placeholder: "Password",
                            text: $password,
                            isSecure: true,
                            isDark: false
                        )
                        .padding(.horizontal, 20)

                        Spacer().frame(height: 16)

                        // Confirm password
                        ScoonTextField(
                            label: "",
                            placeholder: "Confirm password",
                            text: $confirm,
                            isSecure: true,
                            isDark: false
                        )
                        .padding(.horizontal, 20)

                        Spacer().frame(height: 24)

                        // Create account button
                        Button(action: { router.navigate(to: .home) }) {
                            Text("Create account")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color.scoonDark)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.scoonOrange)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal, 20)

                        Spacer().frame(height: 24)

                        // Terms
                        Group {
                            Text("By creating an account or signing you agree to our ")
                                .foregroundColor(Color.black.opacity(0.7))
                            + Text("Terms and Conditions")
                                .fontWeight(.semibold)
                                .underline()
                        }
                        .font(.system(size: 14))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                        Spacer().frame(height: 32)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 9)
                .padding(.top, 39)

                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
}
