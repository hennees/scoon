import SwiftUI

struct WelcomeScreen: View {
    @Environment(AppRouter.self) private var router
    @State private var appeared = false

    var body: some View {
        ZStack {
            // ── Background ────────────────────────────────────────────
            Color.scoonDarker.ignoresSafeArea()

            // Ambient orange glow at bottom
            RadialGradient(
                colors: [Color.scoonOrange.opacity(0.22), .clear],
                center: .init(x: 0.5, y: 1.15),
                startRadius: 0,
                endRadius: UIScreen.main.bounds.height * 0.65
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // ── Hero logo ─────────────────────────────────────────
                VStack(spacing: 10) {
                    Text("scoon")
                        .font(.system(size: 72, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, Color.primary.opacity(0.88)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.75).delay(0.05), value: appeared)

                    Text("YOUR SPOT. YOUR STORY.")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color.scoonOrange.opacity(0.85))
                        .tracking(2.5)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 10)
                        .animation(.spring(response: 0.6, dampingFraction: 0.75).delay(0.15), value: appeared)
                }

                Spacer()

                // ── Feature bullets ───────────────────────────────────
                VStack(spacing: 0) {
                    FeatureBullet(icon: "camera.fill",     text: "Kuratierte Fotospots im DACH-Raum", delay: 0.22)
                    Divider().background(Color.primary.opacity(0.06)).padding(.horizontal, 4)
                    FeatureBullet(icon: "star.fill",       text: "Bewertungen & Community-Tipps",     delay: 0.30)
                    Divider().background(Color.primary.opacity(0.06)).padding(.horizontal, 4)
                    FeatureBullet(icon: "eurosign.circle", text: "Als Creator Geld verdienen",         delay: 0.38)
                }
                .padding(.horizontal, 24)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.primary.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.primary.opacity(0.09), lineWidth: 1)
                        )
                        .padding(.horizontal, 24)
                )
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 16)
                .animation(.spring(response: 0.55, dampingFraction: 0.8).delay(0.25), value: appeared)

                Spacer()

                // ── CTA Buttons ───────────────────────────────────────
                VStack(spacing: 12) {
                    Button(action: { router.navigate(to: .signUpSocial) }) {
                        HStack {
                            Text("Kostenlos starten")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "arrow.right")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.horizontal, 24)
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                        .background(
                            LinearGradient(
                                colors: [Color.scoonOrange, Color(red: 1, green: 0.45, blue: 0.1)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: Color.scoonOrange.opacity(0.45), radius: 16, x: 0, y: 6)
                    }

                    Button(action: { router.navigate(to: .login) }) {
                        Text("Ich habe bereits ein Konto")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white.opacity(0.55))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.primary.opacity(0.07))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.primary.opacity(0.09), lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 24)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .animation(.spring(response: 0.55, dampingFraction: 0.8).delay(0.38), value: appeared)

                Spacer().frame(height: 52)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { appeared = true }
    }
}

private struct FeatureBullet: View {
    let icon:  String
    let text:  String
    let delay: Double

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.scoonOrange.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.scoonOrange)
            }
            Text(text)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.white.opacity(0.8))
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}
