import SwiftUI

struct EinnahmenScreen: View {
    @Environment(AppRouter.self)    private var router
    @Environment(AppContainer.self) private var container
    @State private var vm: EinnahmenViewModel?

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
                        BackButton { router.navigateBack() }
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Einnahmen")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.primary)
                            Text("Creator Dashboard")
                                .font(.system(size: 12))
                                .foregroundColor(Color.scoonOrange)
                        }
                        .padding(.leading, 10)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 56)

                    // ── Period ────────────────────────────────────────
                    HStack(spacing: 8) {
                        Text("letzten 30 Tage")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color.scoonOrange)
                            .padding(.horizontal, 14).padding(.vertical, 7)
                            .background(Color.scoonOrange.opacity(0.1))
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color.scoonOrange.opacity(0.35), lineWidth: 1))
                        Text("17. Feb – 17. Mär 2026")
                            .font(.system(size: 12))
                            .foregroundColor(Color.scoonTextSecondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    // ── Tab row ───────────────────────────────────────
                    HStack(spacing: 0) {
                        SegmentTabButton(title: "Übersicht", isActive: true) {}
                        SegmentTabButton(title: "Transaktionen", isActive: false) {
                            router.navigate(to: .transaktionen)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    if let vm {
                        if vm.isLoading {
                            ProgressView().tint(Color.scoonOrange)
                                .frame(maxWidth: .infinity).padding(.top, 60)
                        } else {
                            let payoutString = Self.currencyFormatter
                                .string(from: NSDecimalNumber(decimal: vm.pendingPayout)) ?? "0,00 €"

                            // ── Payout hero card ──────────────────────
                            VStack(alignment: .leading, spacing: 14) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Nächste Auszahlung")
                                            .font(.system(size: 13))
                                            .foregroundColor(Color.scoonTextSecondary)
                                        Text(payoutString)
                                            .font(.system(size: 36, weight: .bold))
                                            .foregroundColor(.primary)
                                    }
                                    Spacer()
                                    ZStack {
                                        Circle()
                                            .fill(Color.scoonOrange.opacity(0.15))
                                            .frame(width: 54, height: 54)
                                        Image(systemName: "eurosign.circle.fill")
                                            .font(.system(size: 26))
                                            .foregroundColor(Color.scoonOrange)
                                    }
                                }

                                Button(action: {}) {
                                    HStack(spacing: 6) {
                                        Text("Details anzeigen")
                                            .font(.system(size: 14, weight: .semibold))
                                        Image(systemName: "arrow.right")
                                            .font(.system(size: 12))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 18).padding(.vertical, 10)
                                    .background(Color.scoonOrange)
                                    .cornerRadius(10)
                                }
                            }
                            .padding(20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.primary.opacity(0.06))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.primary.opacity(0.09), lineWidth: 1)
                                    )
                            )
                            .padding(.horizontal, 20)
                            .padding(.top, 20)

                            // ── Filter ────────────────────────────────
                            Button(action: {}) {
                                HStack(spacing: 6) {
                                    Image(systemName: "line.3.horizontal.decrease.circle")
                                        .font(.system(size: 14))
                                    Text("Alle Status")
                                        .font(.system(size: 13, weight: .medium))
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 11))
                                }
                                .foregroundColor(Color.scoonTextSecondary)
                                .padding(.horizontal, 14).padding(.vertical, 9)
                                .background(Color.primary.opacity(0.07))
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.primary.opacity(0.09), lineWidth: 1))
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 16)

                            // ── Transactions ──────────────────────────
                            if vm.transactions.isEmpty {
                                VStack(spacing: 16) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.scoonTextSecondary.opacity(0.08))
                                            .frame(width: 72, height: 72)
                                        Image(systemName: "banknote")
                                            .font(.system(size: 30))
                                            .foregroundColor(Color.scoonTextSecondary.opacity(0.4))
                                    }
                                    Text("Noch keine Einnahmen")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color.scoonTextSecondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 50)
                            } else {
                                VStack(spacing: 10) {
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
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            let viewModel = container.makeEinnahmenViewModel()
            vm = viewModel
            await viewModel.onAppear()
        }
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
        HStack(spacing: 14) {
            // Status icon
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(transaction.status.statusColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: transaction.status.statusIcon)
                    .font(.system(size: 18))
                    .foregroundColor(transaction.status.statusColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("\(NSDecimalNumber(decimal: transaction.amount).stringValue) \(transaction.currency)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                Text(Self.dateFormatter.string(from: transaction.date))
                    .font(.system(size: 12))
                    .foregroundColor(Color.scoonTextSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                Text(transaction.status.rawValue)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(transaction.status.statusColor)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(transaction.status.statusColor.opacity(0.14))
                    .cornerRadius(6)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.primary.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.primary.opacity(0.07), lineWidth: 1)
                )
        )
    }
}

