import SwiftUI

struct TransaktionenScreen: View {
    @Environment(AppRouter.self)    private var router
    @Environment(AppContainer.self) private var container
    @State private var vm: TransaktionenViewModel?

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd. MMM yyyy"
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
                            Text("Transaktionen")
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

                    // ── Tabs ──────────────────────────────────────────
                    HStack(spacing: 0) {
                        SegmentTabButton(title: "Übersicht", isActive: false) { router.navigateBack() }
                        SegmentTabButton(title: "Transaktionen", isActive: true) {}
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    if let vm {
                        if vm.isLoading {
                            ProgressView().tint(Color.scoonOrange)
                                .frame(maxWidth: .infinity).padding(.top, 60)
                        } else if vm.transactions.isEmpty {
                            VStack(spacing: 16) {
                                ZStack {
                                    Circle().fill(Color.scoonTextSecondary.opacity(0.08)).frame(width: 72, height: 72)
                                    Image(systemName: "list.bullet.rectangle")
                                        .font(.system(size: 28))
                                        .foregroundColor(Color.scoonTextSecondary.opacity(0.4))
                                }
                                Text("Keine Transaktionen")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color.scoonTextSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 50)
                        } else {
                            VStack(spacing: 10) {
                                ForEach(vm.transactions) { tx in
                                    TransactionCard(transaction: tx, dateFormatter: Self.dateFormatter)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                        }
                    }

                    Spacer().frame(height: 100)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            let viewModel = container.makeTransaktionenViewModel()
            vm = viewModel
            await viewModel.onAppear()
        }
    }
}

// MARK: – Transaction Card

private struct TransactionCard: View {
    let transaction: Transaction
    let dateFormatter: DateFormatter

    var body: some View {
        HStack(spacing: 14) {
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
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.primary)
                Text(dateFormatter.string(from: transaction.date))
                    .font(.system(size: 12))
                    .foregroundColor(Color.scoonTextSecondary)
            }

            Spacer()

            Text(transaction.status.rawValue)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(transaction.status.statusColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(transaction.status.statusColor.opacity(0.14))
                .cornerRadius(8)
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

