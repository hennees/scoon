import SwiftUI

// Design: 619:889 – Opening screen
// Dark background, headline, description, Einloggen + Account erstellen buttons.
struct WelcomeScreen: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        ZStack {
            Color.scoonDark.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Large logo
                Text("scoon")
                    .font(.system(size: 72, weight: .black, design: .rounded))
                    .foregroundColor(.white)

                Spacer().frame(height: 32)

                // Headline
                Text("Entdecke neue\nFotospots in deiner Stadt!")
                    .font(.system(size: 25, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 20)

                Spacer()

                // Description
                Text(
                    "Finde die besten Orte, teile deine Lieblingsspots und lass dich " +
                    "inspirieren – alles mit scoon"
                )
                .font(.system(size: 17))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)

                Spacer().frame(height: 44)

                // Einloggen
                Button(action: { router.navigate(to: .login) }) {
                    Text("Einloggen")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.scoonDark)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.scoonOrange)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 20)

                Spacer().frame(height: 14)

                // Account erstellen
                Button(action: { router.navigate(to: .signUpSocial) }) {
                    Text("Account erstellen")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(white: 0.45), lineWidth: 1)
                        )
                }
                .padding(.horizontal, 20)

                Spacer().frame(height: 50)
            }
        }
        .navigationBarHidden(true)
    }
}
