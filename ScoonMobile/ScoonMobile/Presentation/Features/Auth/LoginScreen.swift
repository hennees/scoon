import SwiftUI

struct LoginScreen: View {
    @Environment(AppRouter.self)    private var router
    @Environment(AppContainer.self) private var container
    @State private var vm: AuthViewModel?

    var body: some View {
        ZStack {
            Color.scoonDark.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("scoon")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.top, 46)
                        .padding(.leading, 15)

                    Text("Einloggen")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                        .tracking(-0.3)
                        .padding(.top, 76)
                        .padding(.leading, 16)

                    if let vm {
                        VStack(spacing: 0) {
                            // Email
                            ScoonTextField(
                                label: "E-Mail-Adresse",
                                placeholder: "E-Mail-Adresse",
                                text: Binding(get: { vm.email }, set: { vm.email = $0 })
                            )
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding(.top, 28)

                            // Password
                            ScoonTextField(
                                label: "Passwort",
                                placeholder: "Passwort",
                                text: Binding(get: { vm.password }, set: { vm.password = $0 }),
                                isSecure: true
                            )
                            .padding(.top, 20)

                            // Forgot password
                            HStack {
                                Spacer()
                                Button(action: {}) {
                                    Text("Passwort vergessen?")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color.scoonTextSecondary)
                                }
                            }
                            .padding(.top, 8)

                            // Error
                            if let error = vm.error {
                                HStack(spacing: 8) {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .foregroundColor(.red)
                                    Text(error)
                                        .font(.system(size: 13))
                                        .foregroundColor(.red)
                                }
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(8)
                                .padding(.top, 12)
                            }

                            // Login button
                            Button(action: { Task { await vm.login() } }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(vm.isLoginValid ? Color.scoonOrange : Color.scoonOrange.opacity(0.5))
                                    if vm.isLoading {
                                        ProgressView().tint(.white)
                                    } else {
                                        Text("Einloggen")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.white)
                                    }
                                }
                                .frame(maxWidth: .infinity).frame(height: 56)
                            }
                            .disabled(vm.isLoading)
                            .padding(.top, 28)

                            // Divider
                            HStack {
                                Rectangle().fill(Color.scoonTextSecondary.opacity(0.4)).frame(height: 1)
                                Text("oder")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color.scoonTextSecondary)
                                    .fixedSize()
                                    .padding(.horizontal, 12)
                                Rectangle().fill(Color.scoonTextSecondary.opacity(0.4)).frame(height: 1)
                            }
                            .padding(.top, 28)

                            // Google Button
                            GoogleSignInButton(isLoading: vm.isLoading) {
                                Task { await vm.signInWithGoogle() }
                            }
                            .padding(.top, 16)
                        }
                        .padding(.horizontal, 16)
                        .onChange(of: vm.isSuccess) { _, success in
                            guard success else { return }
                            router.navigateToRoot()
                            router.navigate(to: .home)
                        }
                    }

                    // Register link
                    HStack(spacing: 4) {
                        Text("Noch kein Konto?")
                            .foregroundColor(.white.opacity(0.7))
                        Button(action: { router.navigate(to: .signUpSocial) }) {
                            Text("Registrieren")
                                .foregroundColor(Color.scoonOrange)
                                .underline()
                                .fontWeight(.semibold)
                        }
                    }
                    .font(.system(size: 14))
                    .frame(maxWidth: .infinity)
                    .padding(.top, 32)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            if vm == nil { vm = container.makeAuthViewModel() }
        }
    }
}

// MARK: – Google Sign-In Button

private struct GoogleSignInButton: View {
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Google G logo
                ZStack {
                    Circle().fill(Color.white).frame(width: 28, height: 28)
                    GoogleGLogo()
                }

                Text("Mit Google fortfahren")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))

                Spacer()

                if isLoading {
                    ProgressView().tint(Color(red: 0.4, green: 0.4, blue: 0.4)).scaleEffect(0.8)
                }
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 2)
        }
        .disabled(isLoading)
    }
}

// MARK: – Google G Logo (drawn with colored text segments)

private struct GoogleGLogo: View {
    var body: some View {
        Canvas { ctx, size in
            let w = size.width
            let h = size.height
            let cx = w / 2
            let cy = h / 2
            let r  = min(w, h) * 0.42

            // Draw 4 colored arcs: blue, red, yellow, green
            let segments: [(Double, Double, Color)] = [
                (-30, 90,  Color(red: 0.26, green: 0.52, blue: 0.96)),  // blue
                (90,  210, Color(red: 0.92, green: 0.26, blue: 0.21)),  // red
                (210, 270, Color(red: 0.99, green: 0.73, blue: 0.01)),  // yellow
                (270, 330, Color(red: 0.20, green: 0.66, blue: 0.33)),  // green
            ]

            for (startDeg, endDeg, color) in segments {
                var path = Path()
                path.addArc(
                    center:     CGPoint(x: cx, y: cy),
                    radius:     r,
                    startAngle: .degrees(startDeg),
                    endAngle:   .degrees(endDeg),
                    clockwise:  false
                )
                ctx.stroke(path, with: .color(color), lineWidth: w * 0.18)
            }

            // White cutout for the "G" gap + horizontal bar
            var gap = Path()
            gap.addArc(
                center: CGPoint(x: cx, y: cy), radius: r,
                startAngle: .degrees(-30), endAngle: .degrees(0), clockwise: false
            )
            ctx.stroke(gap, with: .color(.white), lineWidth: w * 0.18)

            // Horizontal bar of the G
            var bar = Path()
            bar.move(to:    CGPoint(x: cx,     y: cy))
            bar.addLine(to: CGPoint(x: cx + r, y: cy))
            ctx.stroke(bar, with: .color(Color(red: 0.26, green: 0.52, blue: 0.96)), lineWidth: w * 0.18)
        }
        .frame(width: 20, height: 20)
    }
}
