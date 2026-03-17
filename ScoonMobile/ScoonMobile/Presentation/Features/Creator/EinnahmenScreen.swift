import SwiftUI

// Design: 626:1025 – Einnahmen
// Dark, period pill, Übersicht/Transaktionen tabs, next payout card, empty state.
struct EinnahmenScreen: View {
    @Environment(AppRouter.self) private var router

    @State private var selectedTab    = NavTab.profile
    @State private var activeListTab  = 0  // 0 = Übersicht, 1 = Transaktionen

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

                    // Period pill
                    Text("letzten 30 Tage")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Color.scoonDark)
                        .clipShape(Capsule())
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                    // Tabs
                    HStack(spacing: 0) {
                        EinnahmenTabButton(title: "Übersicht", isActive: activeListTab == 0) {
                            activeListTab = 0
                        }
                        EinnahmenTabButton(title: "Transaktionen", isActive: activeListTab == 1) {
                            activeListTab = 1
                            router.navigate(to: .transaktionen)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    // Heading
                    Text("Einnahmen")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                    // Next payout card
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Nächste Auszahlung")
                            .font(.system(size: 13))
                            .foregroundColor(Color.scoonTextSecondary)
                        Text("00.00 €")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        Button(action: {}) {
                            Text("Zeig Details")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 7)
                                .background(Color.scoonOrange.opacity(0.3))
                                .clipShape(Capsule())
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.scoonDark)
                    .cornerRadius(14)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    // Filter row
                    Button(action: {}) {
                        HStack(spacing: 6) {
                            Text("All statuses")
                                .font(.system(size: 13))
                                .foregroundColor(Color.scoonTextSecondary)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 11))
                                .foregroundColor(Color.scoonTextSecondary)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.scoonDark)
                        .cornerRadius(8)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    // Empty state
                    VStack(spacing: 14) {
                        Image(systemName: "shippingbox")
                            .font(.system(size: 48))
                            .foregroundColor(Color.scoonTextSecondary.opacity(0.5))
                        Text("Nichts verfügbar")
                            .font(.system(size: 16))
                            .foregroundColor(Color.scoonTextSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)

                    Spacer().frame(height: 100)
                }
            }

            NavBarView(selectedTab: $selectedTab)
        }
        .navigationBarHidden(true)
    }
}

private struct EinnahmenTabButton: View {
    let title: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 15, weight: isActive ? .semibold : .regular))
                    .foregroundColor(isActive ? Color.scoonOrange : Color.scoonTextSecondary)
                Rectangle()
                    .fill(isActive ? Color.scoonOrange : Color.clear)
                    .frame(height: 2)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
