import SwiftUI

struct EinnahmenScreen: View {
    @Environment(AppRouter.self)    private var router
    @Environment(AppContainer.self) private var container
    @State private var vm: EinnahmenViewModel?
    @State private var showPayoutDetail = false

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

                                Button(action: { showPayoutDetail = true }) {
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
                            Menu {
                                Button("Alle Status") { vm.statusFilter = nil }
                                ForEach(TransactionStatus.allCases, id: \.self) { status in
                                    Button(status.displayLabel) { vm.statusFilter = status }
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "line.3.horizontal.decrease.circle")
                                        .font(.system(size: 14))
                                    Text(vm.statusFilter?.displayLabel ?? "Alle Status")
                                        .font(.system(size: 13, weight: .medium))
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 11))
                                }
                                .foregroundColor(vm.statusFilter != nil ? Color.scoonOrange : Color.scoonTextSecondary)
                                .padding(.horizontal, 14).padding(.vertical, 9)
                                .background(vm.statusFilter != nil ? Color.scoonOrange.opacity(0.12) : Color.primary.opacity(0.07))
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(
                                    vm.statusFilter != nil ? Color.scoonOrange.opacity(0.3) : Color.primary.opacity(0.09),
                                    lineWidth: 1
                                ))
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 16)

                            // ── Transactions ──────────────────────────
                            if vm.filteredTransactions.isEmpty {
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
                                    ForEach(vm.filteredTransactions) { tx in
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
        .sheet(isPresented: $showPayoutDetail) {
            if let vm {
                PayoutDetailSheet(
                    pendingPayout: vm.pendingPayout,
                    pendingTransactions: vm.pendingTransactions
                )
            }
        }
    }
}

// MARK: – Payout Detail Sheet

private struct PayoutDetailSheet: View {
    let pendingPayout: Decimal
    let pendingTransactions: [Transaction]
    @Environment(\.dismiss) private var dismiss

    private static let currencyFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "EUR"
        f.locale = Locale(identifier: "de_AT")
        return f
    }()

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd. MMM yyyy"
        f.locale = Locale(identifier: "de_AT")
        return f
    }()

    var body: some View {
        ZStack {
            Color.scoonDarker.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // Handle
                Capsule()
                    .fill(Color.white.opacity(0.18))
                    .frame(width: 36, height: 4)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 12)

                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("NÄCHSTE AUSZAHLUNG")
                        .font(.system(size: 11, weight: .semibold))
                        .tracking(1.5)
                        .foregroundColor(Color.scoonOrange.opacity(0.8))
                        .padding(.top, 24)
                    Text(Self.currencyFormatter.string(from: NSDecimalNumber(decimal: pendingPayout)) ?? "0,00 €")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)

                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                            .foregroundColor(Color.scoonOrange)
                        Text("Auszahlung am 1. des Monats")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 24)

                // Divider
                Rectangle()
                    .fill(Color.white.opacity(0.07))
                    .frame(height: 1)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)

                // Pending list
                if pendingTransactions.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.4))
                        Text("Keine ausstehenden Transaktionen")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.45))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 8) {
                            ForEach(pendingTransactions) { tx in
                                HStack(spacing: 12) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color(red: 0.95, green: 0.7, blue: 0.0).opacity(0.15))
                                            .frame(width: 36, height: 36)
                                        Image(systemName: "clock.fill")
                                            .font(.system(size: 15))
                                            .foregroundColor(Color(red: 0.95, green: 0.7, blue: 0.0))
                                    }
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("\(NSDecimalNumber(decimal: tx.amount).stringValue) \(tx.currency)")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(.white)
                                        Text(Self.dateFormatter.string(from: tx.date))
                                            .font(.system(size: 12))
                                            .foregroundColor(.white.opacity(0.4))
                                    }
                                    Spacer()
                                    Text("Ausstehend")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(Color(red: 0.95, green: 0.7, blue: 0.0))
                                        .padding(.horizontal, 8).padding(.vertical, 4)
                                        .background(Color(red: 0.95, green: 0.7, blue: 0.0).opacity(0.12))
                                        .cornerRadius(6)
                                }
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.04))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.white.opacity(0.07), lineWidth: 1)
                                        )
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                    }
                }

                Spacer()

                // Close button
                Button(action: { dismiss() }) {
                    Text("Schließen")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            LinearGradient(
                                colors: [Color.scoonOrange, Color(red: 1.0, green: 0.55, blue: 0.15)],
                                startPoint: .leading, endPoint: .trailing
                            )
                            .cornerRadius(16)
                        )
                        .shadow(color: Color.scoonOrange.opacity(0.4), radius: 10, x: 0, y: 4)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .presentationDetents([.medium, .large])
        .presentationCornerRadius(28)
        .presentationBackground(Color.scoonDarker)
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

