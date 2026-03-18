import SwiftUI

struct BecomeCreatorScreen: View {
    @Environment(AppRouter.self)    private var router
    @Environment(AppContainer.self) private var container
    @State private var vm:       BecomeCreatorViewModel?
    @State private var appeared = false

    private let benefits: [(icon: String, title: String, desc: String)] = [
        ("map.badge.plus",       "Eigene Spots erstellen",  "Füge neue Fotolocations zur Karte hinzu und teile sie mit der Community."),
        ("eye.fill",             "Views & Insights",        "Sieh wie viele Menschen deine Spots entdecken und welche am beliebtesten sind."),
        ("eurosign.circle.fill", "Einnahmen verdienen",     "Monetarisiere deine Spots und behalte den Überblick über deine Auszahlungen."),
        ("person.2.fill",        "Eigenes Creator-Profil",  "Hebe dich mit einem Creator-Badge hervor und wachse als Fotograf:in."),
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.scoonDarker.ignoresSafeArea()

            if let vm {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {

                        // ── Header ────────────────────────────────────────
                        HStack {
                            BackButton { router.navigateBack() }
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 56)

                        if vm.isSuccess {
                            successView
                        } else {
                            normalView(vm: vm)
                        }

                        Spacer().frame(height: 100)
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            if vm == nil { vm = container.makeBecomeCreatorViewModel() }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) { appeared = true }
            }
        }
    }

    // MARK: – Normal state

    @ViewBuilder
    private func normalView(vm: BecomeCreatorViewModel) -> some View {

        // ── Hero ──────────────────────────────────────────────────────
        VStack(spacing: 0) {
            ZStack {
                RadialGradient(
                    colors: [Color.scoonOrange.opacity(0.22), Color.clear],
                    center: .center, startRadius: 10, endRadius: 170
                )
                .frame(width: 340, height: 300)

                ZStack {
                    Circle()
                        .fill(Color.scoonOrange.opacity(0.07))
                        .frame(width: 170, height: 170)
                    Circle()
                        .fill(Color.scoonOrange.opacity(0.14))
                        .frame(width: 116, height: 116)
                        .overlay(
                            Circle()
                                .stroke(Color.scoonOrange.opacity(0.32), lineWidth: 1)
                        )
                    Image(systemName: "star.fill")
                        .font(.system(size: 50, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.scoonOrange, Color(red: 1.0, green: 0.6, blue: 0.1)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color.scoonOrange.opacity(0.75), radius: 20, x: 0, y: 4)
                }
            }
            .scaleEffect(appeared ? 1 : 0.55)
            .opacity(appeared ? 1 : 0)
            .animation(.spring(response: 0.55, dampingFraction: 0.7).delay(0.05), value: appeared)

            Text("Creator bei scoon")
                .font(.system(size: 30, weight: .black, design: .rounded))
                .foregroundColor(.primary)
                .padding(.top, 4)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.35).delay(0.13), value: appeared)

            Text("Teile deine Spots, bau eine Community auf\nund verdiene mit deiner Leidenschaft.")
                .font(.system(size: 15))
                .foregroundColor(Color.white.opacity(0.5))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 28)
                .padding(.top, 10)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.35).delay(0.18), value: appeared)
        }
        .frame(maxWidth: .infinity)

        // ── Benefits ──────────────────────────────────────────────────
        VStack(spacing: 10) {
            ForEach(Array(benefits.enumerated()), id: \.offset) { idx, benefit in
                HStack(spacing: 0) {
                    // Orange left accent bar
                    Rectangle()
                        .fill(Color.scoonOrange.opacity(0.7))
                        .frame(width: 3)
                        .padding(.vertical, 16)
                        .cornerRadius(1.5)

                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.scoonOrange.opacity(0.14))
                                .frame(width: 44, height: 44)
                            Image(systemName: benefit.icon)
                                .font(.system(size: 18))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.scoonOrange, Color(red: 1.0, green: 0.6, blue: 0.15)],
                                        startPoint: .topLeading, endPoint: .bottomTrailing
                                    )
                                )
                        }
                        VStack(alignment: .leading, spacing: 3) {
                            Text(benefit.title)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.primary)
                            Text(benefit.desc)
                                .font(.system(size: 12))
                                .foregroundColor(Color.white.opacity(0.45))
                                .lineSpacing(2)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 14)
                }
                .background(Color.primary.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.primary.opacity(0.07), lineWidth: 1)
                )
                .opacity(appeared ? 1 : 0)
                .offset(x: appeared ? 0 : -24)
                .animation(.easeOut(duration: 0.4).delay(0.22 + Double(idx) * 0.07), value: appeared)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 28)

        // ── Error ─────────────────────────────────────────────────────
        if let error = vm.error {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.circle.fill").foregroundColor(.red)
                Text(error).font(.system(size: 13)).foregroundColor(.red)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.red.opacity(0.08))
            .cornerRadius(10)
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }

        // ── CTA ───────────────────────────────────────────────────────
        VStack(spacing: 8) {
            Button(action: { Task { await vm.requestAccess() } }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(
                            LinearGradient(
                                colors: [Color.scoonOrange, Color(red: 1.0, green: 0.55, blue: 0.15)],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                    if vm.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        HStack(spacing: 8) {
                            Image(systemName: "star.fill").font(.system(size: 14, weight: .semibold))
                            Text("Jetzt Creator werden").font(.system(size: 17, weight: .bold))
                        }
                        .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 58)
            }
            .shadow(color: Color.scoonOrange.opacity(0.5), radius: 18, x: 0, y: 7)
            .disabled(vm.isLoading)

            Text("Kostenlos · Kein Vertrag · Jederzeit kündbar")
                .font(.system(size: 12))
                .foregroundColor(Color.white.opacity(0.3))
        }
        .padding(.horizontal, 20)
        .padding(.top, 28)
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.35).delay(0.58), value: appeared)
    }

    // MARK: – Success state

    private var successView: some View {
        VStack(spacing: 0) {
            ZStack {
                RadialGradient(
                    colors: [Color.scoonOrange.opacity(0.22), Color.clear],
                    center: .center, startRadius: 10, endRadius: 140
                )
                .frame(width: 280, height: 280)

                ZStack {
                    Circle()
                        .fill(Color.scoonOrange.opacity(0.14))
                        .frame(width: 120, height: 120)
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.scoonOrange, Color(red: 1.0, green: 0.6, blue: 0.1)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color.scoonOrange.opacity(0.7), radius: 18)
                }
            }
            .padding(.top, 20)

            Text("Willkommen im\nCreator-Team!")
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding(.top, 4)

            Text("Dein Konto ist als Creator freigeschaltet. Du hast jetzt Zugriff auf Insights, Einnahmen und alle Creator-Features.")
                .font(.system(size: 15))
                .foregroundColor(Color.white.opacity(0.5))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 28)
                .padding(.top, 12)

            Button(action: { router.navigateBack() }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(
                            LinearGradient(
                                colors: [Color.scoonOrange, Color(red: 1.0, green: 0.55, blue: 0.15)],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                    Text("Zum Profil")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 58)
            }
            .shadow(color: Color.scoonOrange.opacity(0.5), radius: 18, x: 0, y: 7)
            .padding(.horizontal, 20)
            .padding(.top, 32)
        }
        .frame(maxWidth: .infinity)
    }
}
