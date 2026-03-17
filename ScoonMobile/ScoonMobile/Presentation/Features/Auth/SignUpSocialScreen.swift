import SwiftUI

// Design: 619:875 – Sign Up 1
// Light card (upper ~83%) with logo + text; dark lower section with social buttons.
struct SignUpSocialScreen: View {
    @Environment(AppRouter.self) private var router

    // Figma asset URLs (valid ~7 days from design export)
    private let googleLogoURL = "https://www.figma.com/api/mcp/asset/0a1d3e6f-afa1-46a7-89b0-83f53bd251e2"
    private let messageIconURL = "https://www.figma.com/api/mcp/asset/a39d5741-3cb9-482f-8d88-1d060368d722"

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

                        Spacer().frame(height: 24)

                        // Heading
                        Text("Entdecke scoon")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.black)
                            .tracking(-0.3)

                        Spacer().frame(height: 12)

                        // Description
                        Text(
                            "Finde die besten Fotospots, teile deine Highlights und entdecke " +
                            "neue Perspektiven in deiner Stadt."
                        )
                        .font(.system(size: 16))
                        .foregroundColor(Color.black.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)

                        Spacer().frame(height: 48)

                        // Continue with Google
                        SocialButton(
                            icon: { AsyncImage(url: URL(string: "https://www.figma.com/api/mcp/asset/0a1d3e6f-afa1-46a7-89b0-83f53bd251e2")) { img in img.resizable().scaledToFit() } placeholder: { Image(systemName: "g.circle").resizable().scaledToFit() }.frame(width: 20, height: 20) },
                            label: "Continue with Google"
                        ) {}

                        Spacer().frame(height: 16)

                        // Continue with Apple
                        SocialButton(
                            icon: { Image(systemName: "apple.logo").resizable().scaledToFit().frame(width: 18, height: 20) },
                            label: "Continue with Apple"
                        ) {}

                        Spacer().frame(height: 16)

                        // Continue with Email
                        SocialButton(
                            icon: { Image(systemName: "envelope").resizable().scaledToFit().frame(width: 20, height: 16) },
                            label: "Continue with Email"
                        ) { router.navigate(to: .signUpForm) }

                        Spacer().frame(height: 28)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 9)
                .padding(.top, 39)

                // Bottom link
                Spacer()
                HStack(spacing: 4) {
                    Text("Bereits ein Konto?")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                    Button(action: { router.navigate(to: .login) }) {
                        Text("Jetzt anmelden!")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color.scoonOrange)
                            .underline()
                    }
                }
                Spacer().frame(height: 32)
            }
        }
        .navigationBarHidden(true)
    }
}

private struct SocialButton<Icon: View>: View {
    @ViewBuilder let icon: Icon
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                icon
                    .foregroundColor(.white)
                Text(label)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 19)
            .frame(height: 56)
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color.scoonBorder, lineWidth: 1)
            )
        }
        .padding(.horizontal, 20)
    }
}
