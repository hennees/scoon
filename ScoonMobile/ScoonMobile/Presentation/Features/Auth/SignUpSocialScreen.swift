import SwiftUI

struct SignUpSocialScreen: View {
    @Environment(AppRouter.self)    private var router
    @Environment(AppContainer.self) private var container
    @State private var vm: AuthViewModel?
    @State private var appeared = false

    var body: some View {
        ZStack {
            Color.scoonDarker.ignoresSafeArea()

            RadialGradient(
                colors: [Color.scoonOrange.opacity(0.14), .clear],
                center: .init(x: 0.5, y: 1.1),
                startRadius: 0,
                endRadius: UIScreen.main.bounds.height * 0.55
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Back ──────────────────────────────────────────────
                HStack {
                    BackButton { router.navigateBack() }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 56)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.3), value: appeared)

                Spacer()

                // ── Title ─────────────────────────────────────────────
                VStack(spacing: 8) {
                    Text("scoon")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, Color.primary.opacity(0.85)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)
                        .animation(.spring(response: 0.55, dampingFraction: 0.75).delay(0.05), value: appeared)

                    Text("Konto erstellen")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.primary)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 12)
                        .animation(.spring(response: 0.55, dampingFraction: 0.75).delay(0.1), value: appeared)

                    Text("Wähle eine Registrierungsmethode")
                        .font(.system(size: 15))
                        .foregroundColor(Color.scoonTextSecondary)
                        .padding(.top, 4)
                        .opacity(appeared ? 1 : 0)
                        .animation(.easeOut(duration: 0.4).delay(0.15), value: appeared)
                }

                Spacer()

                // ── Auth options ──────────────────────────────────────
                VStack(spacing: 14) {
                    // Error
                    if let error = vm?.error {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.circle.fill").foregroundColor(.red)
                            Text(error).font(.system(size: 13)).foregroundColor(.red)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.red.opacity(0.2), lineWidth: 1))
                    }

                    // Google
                    if let vm {
                        GoogleRegisterButton(isLoading: vm.isLoading) {
                            Task { await vm.signInWithGoogle() }
                        }
                    }

                    // Divider
                    HStack {
                        Rectangle().fill(Color.primary.opacity(0.1)).frame(height: 1)
                        Text("oder")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.3))
                            .padding(.horizontal, 14)
                        Rectangle().fill(Color.primary.opacity(0.1)).frame(height: 1)
                    }

                    // E-Mail
                    Button(action: { router.navigate(to: .signUpForm) }) {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.primary.opacity(0.15))
                                    .frame(width: 32, height: 32)
                                Image(systemName: "envelope.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.primary)
                            }
                            Text("Mit E-Mail registrieren")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "arrow.right")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .padding(.horizontal, 18)
                        .frame(maxWidth: .infinity).frame(height: 56)
                        .background(Color.primary.opacity(0.08))
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 24)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .animation(.easeOut(duration: 0.4).delay(0.2), value: appeared)

                Spacer().frame(height: 28)

                // ── Login link ────────────────────────────────────────
                HStack(spacing: 4) {
                    Text("Bereits ein Konto?")
                        .foregroundColor(.white.opacity(0.4))
                    Button(action: { router.navigate(to: .login) }) {
                        Text("Anmelden")
                            .foregroundColor(Color.scoonOrange)
                            .fontWeight(.semibold)
                    }
                }
                .font(.system(size: 14))
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.4).delay(0.25), value: appeared)

                Spacer().frame(height: 48)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            if vm == nil { vm = container.makeAuthViewModel() }
            appeared = true
        }
        .onChange(of: vm?.isSuccess) { _, success in
            guard success == true else { return }
            router.login()
        }
    }
}

private struct GoogleRegisterButton: View {
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(.white).frame(width: 28, height: 28)
                    GoogleGMark()
                }
                Text("Mit Google fortfahren")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                Spacer()
                if isLoading {
                    ProgressView().tint(.gray).scaleEffect(0.8)
                }
            }
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity).frame(height: 56)
            .background(.white)
            .cornerRadius(14)
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 3)
        }
        .disabled(isLoading)
    }
}

struct GoogleGMark: View {
    var body: some View {
        Canvas { ctx, size in
            let cx = size.width / 2
            let cy = size.height / 2
            let r  = min(size.width, size.height) * 0.42
            let lw = size.width * 0.18

            let arcs: [(Double, Double, Color)] = [
                (-30,  90,  Color(red: 0.26, green: 0.52, blue: 0.96)),
                ( 90,  210, Color(red: 0.92, green: 0.26, blue: 0.21)),
                (210,  270, Color(red: 0.99, green: 0.73, blue: 0.01)),
                (270,  330, Color(red: 0.20, green: 0.66, blue: 0.33)),
            ]
            for (s, e, c) in arcs {
                var p = Path()
                p.addArc(center: CGPoint(x: cx, y: cy), radius: r,
                         startAngle: .degrees(s), endAngle: .degrees(e), clockwise: false)
                ctx.stroke(p, with: .color(c), lineWidth: lw)
            }
            var gap = Path()
            gap.addArc(center: CGPoint(x: cx, y: cy), radius: r,
                       startAngle: .degrees(-30), endAngle: .degrees(0), clockwise: false)
            ctx.stroke(gap, with: .color(.white), lineWidth: lw)
            var bar = Path()
            bar.move(to: CGPoint(x: cx, y: cy))
            bar.addLine(to: CGPoint(x: cx + r, y: cy))
            ctx.stroke(bar, with: .color(Color(red: 0.26, green: 0.52, blue: 0.96)), lineWidth: lw)
        }
        .frame(width: 20, height: 20)
    }
}
