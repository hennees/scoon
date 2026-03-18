import SwiftUI

struct OnboardingScreen: View {
    let onFinish: () -> Void

    @State private var currentPage   = 0
    @State private var slideAppeared = false

    private let slides: [OnboardingSlide] = [
        .init(icon: "map.fill",    title: "Entdecke\nFoto-Spots",     description: "Finde die schönsten Orte zum Fotografieren – kuratiert von echten Fotografen."),
        .init(icon: "camera.fill", title: "Teile deine\nbesten Fotos", description: "Lade deine Aufnahmen hoch und zeige der Community, was du an diesem Spot gesehen hast."),
        .init(icon: "star.fill",   title: "Werde\nCreator",            description: "Erstelle eigene Spots, bau eine Community auf und verdiene mit deiner Leidenschaft."),
        .init(icon: "bolt.fill",   title: "Leg jetzt\nlos",            description: "Dein nächstes Foto-Abenteuer wartet. Melde dich an und starte sofort."),
    ]

    var body: some View {
        ZStack {
            Color.scoonDarker.ignoresSafeArea()

            // Atmospheric orange ambient glow
            RadialGradient(
                colors: [Color.scoonOrange.opacity(0.18), Color.clear],
                center: .init(x: 0.5, y: 0.36),
                startRadius: 10,
                endRadius: 340
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {

                // ── scoon wordmark ─────────────────────────────────────
                Text("scoon")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.primary, Color.scoonOrange],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .padding(.top, 60)

                // ── Slides ─────────────────────────────────────────────
                TabView(selection: $currentPage) {
                    ForEach(slides.indices, id: \.self) { idx in
                        OnboardingSlideView(
                            slide:    slides[idx],
                            isActive: slideAppeared && currentPage == idx
                        )
                        .tag(idx)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentPage)

                // ── Dot indicators ─────────────────────────────────────
                HStack(spacing: 6) {
                    ForEach(slides.indices, id: \.self) { idx in
                        Capsule()
                            .fill(idx == currentPage
                                  ? Color.scoonOrange
                                  : Color.white.opacity(0.18))
                            .frame(width: idx == currentPage ? 22 : 6, height: 6)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                    }
                }
                .padding(.bottom, 28)

                // ── CTA button ─────────────────────────────────────────
                Button(action: advance) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(
                                LinearGradient(
                                    colors: [Color.scoonOrange, Color(red: 1.0, green: 0.55, blue: 0.15)],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                        HStack(spacing: 8) {
                            Text(currentPage < slides.count - 1 ? "Weiter" : "Jetzt starten")
                                .font(.system(size: 17, weight: .bold))
                            Image(systemName: currentPage < slides.count - 1 ? "arrow.right" : "bolt.fill")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 58)
                }
                .shadow(color: Color.scoonOrange.opacity(0.5), radius: 20, x: 0, y: 8)
                .padding(.horizontal, 24)
                .animation(.easeInOut(duration: 0.2), value: currentPage)

                // ── Skip ───────────────────────────────────────────────
                Button(action: onFinish) {
                    Text(currentPage < slides.count - 1 ? "Überspringen" : " ")
                        .font(.system(size: 14))
                        .foregroundColor(Color.white.opacity(0.3))
                }
                .frame(height: 48)
                .padding(.bottom, 16)
            }
        }
        .onAppear    { triggerSlideAnimation() }
        .onChange(of: currentPage) { _, _ in
            slideAppeared = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) { triggerSlideAnimation() }
        }
    }

    private func advance() {
        if currentPage < slides.count - 1 {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { currentPage += 1 }
        } else {
            onFinish()
        }
    }

    private func triggerSlideAnimation() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) { slideAppeared = true }
    }
}

// MARK: – Slide View

private struct OnboardingSlideView: View {
    let slide:    OnboardingSlide
    let isActive: Bool

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // ── Icon with atmospheric glow rings ──────────────────────
            ZStack {
                Circle()
                    .fill(Color.scoonOrange.opacity(0.05))
                    .frame(width: 240, height: 240)
                Circle()
                    .fill(Color.scoonOrange.opacity(0.09))
                    .frame(width: 172, height: 172)
                Circle()
                    .fill(Color.scoonOrange.opacity(0.16))
                    .frame(width: 116, height: 116)
                    .overlay(
                        Circle()
                            .stroke(Color.scoonOrange.opacity(0.35), lineWidth: 1)
                    )
                Image(systemName: slide.icon)
                    .font(.system(size: 52, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.scoonOrange, Color(red: 1.0, green: 0.6, blue: 0.2)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color.scoonOrange.opacity(0.8), radius: 22, x: 0, y: 4)
            }
            .scaleEffect(isActive ? 1.0 : 0.5)
            .opacity(isActive ? 1 : 0)
            .animation(.spring(response: 0.6, dampingFraction: 0.65), value: isActive)

            // ── Title ─────────────────────────────────────────────────
            Text(slide.title)
                .font(.system(size: 46, weight: .black, design: .rounded))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineSpacing(1)
                .padding(.top, 36)
                .opacity(isActive ? 1 : 0)
                .offset(y: isActive ? 0 : 26)
                .animation(.easeOut(duration: 0.45).delay(0.08), value: isActive)

            // ── Description ───────────────────────────────────────────
            Text(slide.description)
                .font(.system(size: 16))
                .foregroundColor(Color.white.opacity(0.5))
                .multilineTextAlignment(.center)
                .lineSpacing(5)
                .padding(.horizontal, 40)
                .padding(.top, 16)
                .opacity(isActive ? 1 : 0)
                .offset(y: isActive ? 0 : 16)
                .animation(.easeOut(duration: 0.45).delay(0.15), value: isActive)

            Spacer()
            Spacer()
        }
    }
}

// MARK: – Model

private struct OnboardingSlide {
    let icon:        String
    let title:       String
    let description: String
}
