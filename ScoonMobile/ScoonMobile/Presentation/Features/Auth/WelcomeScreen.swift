import SwiftUI

struct WelcomeScreen: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        ZStack {
            Color.scoonDark.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Logo
                VStack(spacing: 8) {
                    Text("scoon")
                        .font(.system(size: 64, weight: .black, design: .rounded))
                        .foregroundColor(.white)

                    Text("Entdecke die besten Fotospots\nin deiner Stadt.")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.55))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }

                Spacer()

                // Feature bullets
                VStack(spacing: 14) {
                    FeatureBullet(icon: "camera.fill",     text: "Kuratierte Fotospots im DACH-Raum")
                    FeatureBullet(icon: "star.fill",       text: "Bewertungen & Empfehlungen der Community")
                    FeatureBullet(icon: "eurosign.circle", text: "Als Creator Geld verdienen")
                }
                .padding(.horizontal, 32)

                Spacer()

                // CTA Buttons
                VStack(spacing: 12) {
                    Button(action: { router.navigate(to: .signUpSocial) }) {
                        Text("Kostenlos starten")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.scoonOrange)
                            .cornerRadius(14)
                    }

                    Button(action: { router.navigate(to: .login) }) {
                        Text("Ich habe bereits ein Konto")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(14)
                    }
                }
                .padding(.horizontal, 24)

                Spacer().frame(height: 48)
            }
        }
        .navigationBarHidden(true)
    }
}

private struct FeatureBullet: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundColor(Color.scoonOrange)
                .frame(width: 22)
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.75))
            Spacer()
        }
    }
}
