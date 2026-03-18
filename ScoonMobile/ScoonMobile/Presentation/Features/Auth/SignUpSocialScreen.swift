import SwiftUI

/// Registrierung – Methode wählen: Google oder E-Mail
struct SignUpSocialScreen: View {
    @Environment(AppRouter.self)    private var router
    @Environment(AppContainer.self) private var container
    @State private var vm: AuthViewModel?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // Back
                HStack {
                    Button(action: { router.navigateBack() }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 52)

                Spacer()

                VStack(spacing: 8) {
                    Text("scoon")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundColor(.white)

                    Text("Konto erstellen")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 4)

                    Text("Wähle eine Registrierungsmethode")
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.45))
                        .padding(.top, 8)
                }

                Spacer()

                // Error
                if let error = vm?.error {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.circle.fill").foregroundColor(.red)
                        Text(error).font(.system(size: 13)).foregroundColor(.red)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                }

                VStack(spacing: 14) {
                    // Google
                    if let vm {
                        GoogleRegisterButton(isLoading: vm.isLoading) {
                            Task { await vm.signInWithGoogle() }
                        }
                    }

                    // Divider
                    HStack {
                        Rectangle().fill(Color.white.opacity(0.12)).frame(height: 1)
                        Text("oder")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.35))
                            .padding(.horizontal, 14)
                        Rectangle().fill(Color.white.opacity(0.12)).frame(height: 1)
                    }

                    // E-Mail
                    Button(action: { router.navigate(to: .signUpForm) }) {
                        HStack(spacing: 12) {
                            Image(systemName: "envelope.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                            Text("Mit E-Mail registrieren")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(14)
                    }
                }
                .padding(.horizontal, 24)

                Spacer().frame(height: 32)

                // Login link
                HStack(spacing: 4) {
                    Text("Bereits ein Konto?")
                        .foregroundColor(.white.opacity(0.45))
                    Button(action: { router.navigate(to: .login) }) {
                        Text("Anmelden")
                            .foregroundColor(Color.scoonOrange)
                            .fontWeight(.semibold)
                    }
                }
                .font(.system(size: 14))

                Spacer().frame(height: 48)
            }
        }
        .navigationBarHidden(true)
        .onAppear { if vm == nil { vm = container.makeAuthViewModel() } }
        .onChange(of: vm?.isSuccess) { _, success in
            guard success == true else { return }
            router.navigateToRoot()
            router.navigate(to: .home)
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
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(.white)
            .cornerRadius(14)
            .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 2)
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
            // Gap
            var gap = Path()
            gap.addArc(center: CGPoint(x: cx, y: cy), radius: r,
                       startAngle: .degrees(-30), endAngle: .degrees(0), clockwise: false)
            ctx.stroke(gap, with: .color(.white), lineWidth: lw)
            // Bar
            var bar = Path()
            bar.move(to: CGPoint(x: cx, y: cy))
            bar.addLine(to: CGPoint(x: cx + r, y: cy))
            ctx.stroke(bar, with: .color(Color(red: 0.26, green: 0.52, blue: 0.96)), lineWidth: lw)
        }
        .frame(width: 20, height: 20)
    }
}
