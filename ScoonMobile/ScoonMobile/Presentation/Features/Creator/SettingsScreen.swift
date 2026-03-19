import SwiftUI
import CoreLocation

struct SettingsScreen: View {
    @Environment(AppRouter.self)    private var router
    @Environment(AppContainer.self) private var container

    @AppStorage("isDarkMode")             private var darkModeEnabled:      Bool = true
    @AppStorage("analytics_tracking_enabled") private var trackingEnabled:  Bool = true
    @State private var liveLocation       = true
    @State private var vm: AuthViewModel?
    @State private var showSignOutConfirm  = false
    @State private var isCreator: Bool     = false
    @State private var showLanguageDialog  = false
    @State private var locationStatus: CLAuthorizationStatus = .notDetermined

    private var locationStatusLabel: String {
        switch locationStatus {
        case .authorizedAlways:  return "Immer"
        case .authorizedWhenInUse: return "Während der Nutzung"
        case .denied:            return "Verweigert"
        case .restricted:        return "Eingeschränkt"
        default:                 return "Nicht festgelegt"
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.scoonDarker.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    // ── Header ────────────────────────────────────────
                    HStack {
                        BackButton { router.navigateBack() }
                        Text("Einstellungen")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                            .padding(.leading, 10)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 56)

                    // ── Account Section ───────────────────────────────
                    SettingsSectionLabel("Account")

                    SettingsCard {
                        SettingsRow(icon: "person.circle.fill", iconBg: Color(red: 0.2, green: 0.5, blue: 1.0),
                                    title: "Profil") { router.navigate(to: .profile) }
                        SettingsDividerLine()
                        SettingsRow(icon: "globe", iconBg: Color(red: 0.3, green: 0.7, blue: 0.4),
                                    title: "Sprache") { showLanguageDialog = true }
                        SettingsDividerLine()
                        SettingsRow(
                            icon: "location.fill",
                            iconBg: Color(red: 0.0, green: 0.6, blue: 0.9),
                            title: "Standort",
                            subtitle: locationStatusLabel
                        ) {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }
                        SettingsDividerLine()
                        SettingsToggleRow(
                            icon: "chart.bar.fill",
                            iconBg: Color(red: 0.55, green: 0.35, blue: 0.9),
                            title: "Tracking & Analytics",
                            isOn: $trackingEnabled
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                    // ── Creator Section ───────────────────────────────
                    SettingsSectionLabel("Creator")

                    Group {
                        if isCreator {
                            SettingsCard {
                                SettingsRow(icon: "chart.line.uptrend.xyaxis", iconBg: Color.scoonOrange,
                                            title: "Insights") { router.navigate(to: .insights) }
                                SettingsDividerLine()
                                SettingsRow(icon: "eurosign.circle.fill", iconBg: Color(red: 0.2, green: 0.75, blue: 0.4),
                                            title: "Einnahmen") { router.navigate(to: .einnahmen) }
                                SettingsDividerLine()
                                SettingsRow(icon: "list.bullet.rectangle", iconBg: Color(red: 0.5, green: 0.35, blue: 0.85),
                                            title: "Transaktionen") { router.navigate(to: .transaktionen) }
                            }
                        } else {
                            SettingsCard {
                                SettingsRow(icon: "star.fill", iconBg: Color.scoonOrange,
                                            title: "Creator werden") { router.navigate(to: .becomeCreator) }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                    // ── Darstellung Section ───────────────────────────
                    SettingsSectionLabel("Darstellung")

                    SettingsCard {
                        SettingsToggleRow(icon: "moon.fill", iconBg: Color(red: 0.35, green: 0.3, blue: 0.8),
                                         title: "Dark Mode", isOn: $darkModeEnabled)
                        SettingsDividerLine()
                        SettingsToggleRow(icon: "location.fill", iconBg: Color(red: 0.0, green: 0.6, blue: 0.9),
                                         title: "Live Standort", isOn: $liveLocation)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                    // ── Rechtliches Section ───────────────────────────
                    SettingsSectionLabel("Rechtliches & Info")

                    SettingsCard {
                        SettingsRow(icon: "lock.shield.fill", iconBg: Color(red: 0.25, green: 0.55, blue: 0.95),
                                    title: "Datenschutz", hasExternalLink: true) {
                            router.navigate(to: .privacyPolicy)
                        }
                        SettingsDividerLine()
                        SettingsRow(icon: "doc.text.fill", iconBg: Color(red: 0.5, green: 0.5, blue: 0.55),
                                    title: "Nutzungsbedingungen", hasExternalLink: true) {
                            router.navigate(to: .termsOfService)
                        }
                        SettingsDividerLine()
                        SettingsRow(icon: "info.circle.fill", iconBg: Color(red: 0.3, green: 0.65, blue: 0.85),
                                    title: "Impressum", hasExternalLink: true) {
                            router.navigate(to: .imprint)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                    // ── App version ───────────────────────────────────
                    Text("scoon · Version 1.0.0")
                        .font(.system(size: 12))
                        .foregroundColor(Color.scoonTextSecondary.opacity(0.5))
                        .frame(maxWidth: .infinity)
                        .padding(.top, 20)

                    // ── Sign Out ──────────────────────────────────────
                    Button(action: { showSignOutConfirm = true }) {
                        HStack(spacing: 12) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 16))
                                .foregroundColor(.red)
                            Text("Abmelden")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.red)
                            Spacer()
                            if vm?.isLoading == true {
                                ProgressView().tint(.red).scaleEffect(0.8)
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.red.opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.red.opacity(0.18), lineWidth: 1)
                                )
                        )
                    }
                    .disabled(vm?.isLoading == true)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    Spacer().frame(height: 110)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            if vm == nil { vm = container.makeAuthViewModel() }
            locationStatus = CLLocationManager().authorizationStatus
        }
        .confirmationDialog(
            "Sprache ändern",
            isPresented: $showLanguageDialog,
            titleVisibility: .visible
        ) {
            Button("In den iOS-Einstellungen öffnen") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Abbrechen", role: .cancel) {}
        } message: {
            Text("Die App-Sprache kann in den iOS-Einstellungen geändert werden.")
        }
        .task {
            if let user = try? await container.userRepository.fetchCurrentUser() {
                isCreator = user.isCreator
            }
            for await notification in NotificationCenter.default.notifications(named: .profileUpdated) {
                if let user = notification.object as? User {
                    isCreator = user.isCreator
                }
            }
        }
        .confirmationDialog("Wirklich abmelden?", isPresented: $showSignOutConfirm, titleVisibility: .visible) {
            Button("Abmelden", role: .destructive) {
                Task { await vm?.signOut() }
            }
            Button("Abbrechen", role: .cancel) {}
        }
        .onChange(of: vm?.isSignedOut) { _, signedOut in
            guard signedOut == true else { return }
            router.logout()
        }
    }
}

// MARK: – Section Label

private struct SettingsSectionLabel: View {
    let title: String
    init(_ title: String) { self.title = title }

    var body: some View {
        Text(title.uppercased())
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(Color.scoonTextSecondary.opacity(0.7))
            .tracking(1.2)
            .padding(.horizontal, 32)
            .padding(.top, 24)
            .padding(.bottom, 4)
    }
}

// MARK: – Card Container

private struct SettingsCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.primary.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

// MARK: – Settings Row

private struct SettingsRow: View {
    let icon: String
    let iconBg: Color
    let title: String
    var subtitle: String? = nil
    var hasExternalLink: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconBg)
                        .frame(width: 32, height: 32)
                    Image(systemName: icon)
                        .font(.system(size: 15))
                        .foregroundColor(.white)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: 12))
                            .foregroundColor(Color.scoonTextSecondary)
                    }
                }
                Spacer()
                Image(systemName: hasExternalLink ? "arrow.up.right" : "chevron.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.scoonTextSecondary.opacity(0.6))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
        }
        .buttonStyle(.plain)
    }
}

// MARK: – Toggle Row

private struct SettingsToggleRow: View {
    let icon: String
    let iconBg: Color
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconBg)
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
            }
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.primary)
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color.scoonOrange)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
    }
}

// MARK: – Divider

private struct SettingsDividerLine: View {
    var body: some View {
        Rectangle()
            .fill(Color.primary.opacity(0.07))
            .frame(height: 0.5)
            .padding(.leading, 62)
    }
}
