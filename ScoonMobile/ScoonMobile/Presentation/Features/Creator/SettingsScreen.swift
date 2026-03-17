import SwiftUI

// Design: 343:224 – Settings
// Dark, "scoon" header, grouped sections with toggles, NavBar (profile active).
struct SettingsScreen: View {
    @Environment(AppRouter.self) private var router

    @State private var selectedTab      = NavTab.profile
    @State private var darkModeEnabled  = false
    @State private var liveLocation     = true

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.scoonDarker.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    HStack {
                        Button(action: { router.navigateBack() }) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(Color.scoonOrange)
                        }
                        Text("scoon")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.leading, 8)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 56)

                    // Account Section
                    SectionHeader(title: "Account")

                    SettingsRow(icon: "person.circle", title: "Profil") {
                        router.navigate(to: .profile)
                    }
                    SettingsDivider()
                    SettingsRow(icon: "globe", title: "Sprache") {}
                    SettingsDivider()
                    SettingsRow(icon: "location", title: "Standort") {}
                    SettingsDivider()
                    SettingsRow(icon: "chart.bar", title: "Tracking") {}

                    // Darstellung Section
                    SectionHeader(title: "Darstellung & Anzeige")

                    SettingsToggleRow(icon: "moon.fill", title: "Darkmode", isOn: $darkModeEnabled)
                    SettingsDivider()
                    SettingsToggleRow(icon: "location.fill", title: "Live Standort", isOn: $liveLocation)

                    // Rechtliches Section
                    SectionHeader(title: "Rechtliches & Info")

                    SettingsRow(icon: "lock.shield", title: "Datenschutz", hasExternalLink: true) {}
                    SettingsDivider()
                    SettingsRow(icon: "doc.text", title: "Nutzungsbedingungen", hasExternalLink: true) {}
                    SettingsDivider()
                    SettingsRow(icon: "info.circle", title: "Impressum", hasExternalLink: true) {}

                    Spacer().frame(height: 100)
                }
            }

            NavBarView(selectedTab: $selectedTab)
        }
        .navigationBarHidden(true)
    }
}

private struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(Color.scoonOrange)
            .padding(.horizontal, 20)
            .padding(.top, 28)
            .padding(.bottom, 8)
    }
}

private struct SettingsRow: View {
    let icon: String
    let title: String
    var hasExternalLink: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(Color.scoonTextSecondary)
                    .frame(width: 24)
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: hasExternalLink ? "arrow.up.right.square" : "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(Color.scoonTextSecondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(Color.scoonDark)
        }
    }
}

private struct SettingsToggleRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(Color.scoonTextSecondary)
                .frame(width: 24)
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.white)
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color(red: 0.49, green: 0.33, blue: 0.83))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color.scoonDark)
    }
}

private struct SettingsDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.scoonTextSecondary.opacity(0.15))
            .frame(height: 1)
            .padding(.leading, 58)
    }
}
