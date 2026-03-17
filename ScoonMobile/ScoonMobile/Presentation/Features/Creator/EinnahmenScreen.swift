import SwiftUI

// Design: 626:1025 – Einnahmen
struct EinnahmenScreen: View {
    @Environment(AppRouter.self)    private var router
    @Environment(AppContainer.self) private var container
    @State private var vm: EinnahmenViewModel?

    @State private var selectedTab   = NavTab.profile
    @State private var activeListTab = 0  // 0 = Übersicht, 1 = Transaktionen

    private static let currencyFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "EUR"
        f.locale = Locale(identifier: "de_AT")
        return f
    }()

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.scoonDarker.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // ── Header ────────────────────────────────────────
                    HStack {
                        Button(action: { router.navigateBack() }) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(Color.scoonOrange)
                        }
                        Text("scoon")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.leading, 8)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 56)

                    // ── Period pill ───────────────────────────────────
                    Text("letzten 30 Tage")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14).padding(.vertical, 6)
                        .background(Color.white.opacity(0.07))
                        .clipShape(Capsule())
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                    // ── Tabs ──────────────────────────────────────────
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

                    Text("Einnahmen")
                        .font(.system(size: 26, weight: .heavy))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                    if let vm {
                        if vm.isLoading {
                            ProgressView().tint(Color.scoonOrange)
                                .frame(maxWidth: .infinity).padding(.top, 40)
                        } else {
                            // ── Payout card ───────────────────────────
                            let payoutString = Self.currencyFormatter
                                .string(from: NSDecimalNumber(decimal: vm.pendingPayout)) ?? "0,00 €"

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Nächste Auszahlung")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color.scoonTextSecondary)
                                Text(payoutString)
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                                Button(action: {}) {
                                    Text("Zeig Details")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16).padding(.vertical, 7)
                                        .background(Color.scoonOrange.opacity(0.3))
                                        .clipShape(Capsule())
                                }
                            }
                            .padding(20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.06))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                                    )
                            )
                            .padding(.horizontal, 20)
                            .padding(.top, 16)

                            // ── Filter row ────────────────────────────
                            Button(action: {}) {
                                HStack(spacing: 6) {
                                    Text("Alle Status")
                                        .font(.system(size: 13))
                                        .foregroundColor(Color.scoonTextSecondary)
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 11))
                                        .foregroundColor(Color.scoonTextSecondary)
                                }
                                .padding(.horizontal, 14).padding(.vertical, 8)
                                .background(Color.white.opacity(0.07))
                                .cornerRadius(8)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 16)

                            // ── List or empty state ───────────────────
                            if vm.transactions.isEmpty {
                                VStack(spacing: 14) {
                                    Image(systemName: "banknote")
                                        .font(.system(size: 48))
                                        .foregroundColor(Color.scoonTextSecondary.opacity(0.4))
                                    Text("Noch keine Einnahmen")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color.scoonTextSecondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.top, 50)
                            } else {
                                VStack(spacing: 12) {
                                    ForEach(vm.transactions) { tx in
                                        EinnahmenTransactionCard(transaction: tx)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, 16)
                            }
                        }
                    }

                    Spacer().frame(height: 100)
                }
            }

            NavBarView(selectedTab: $selectedTab)
        }
        .navigationBarHidden(true)
        .task {
            let viewModel = container.makeEinnahmenViewModel()
            vm = viewModel
            await viewModel.onAppear()
        }
    }
}

// MARK: – Tab Button

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
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isActive)
    }
}

// MARK: – Transaction Card

private struct EinnahmenTransactionCard: View {
    let transaction: Transaction

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd. MMM yyyy"
        f.locale = Locale(identifier: "de_AT")
        return f
    }()

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(NSDecimalNumber(decimal: transaction.amount).stringValue) \(transaction.currency)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                Text(Self.dateFormatter.string(from: transaction.date))
                    .font(.system(size: 13))
                    .foregroundColor(Color.scoonTextSecondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 8) {
                Text(transaction.status.rawValue)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(transaction.status.uiColor)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(transaction.status.uiColor.opacity(0.15))
                    .cornerRadius(6)
                Button(action: {}) {
                    Text("Zeig Details")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14).padding(.vertical, 6)
                        .background(transaction.status.uiColor.opacity(0.25))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.07), lineWidth: 1)
                )
        )
    }
}

// MARK: – Status Color

private extension TransactionStatus {
    var uiColor: Color {
        switch self {
        case .paid:    return Color(red: 0.2,  green: 0.8,  blue: 0.4)
        case .pending: return Color(red: 0.85, green: 0.65, blue: 0.0)
        case .failed:  return Color.red
        }
    }
}
