import SwiftUI

// Design: 629:794 – Transaktionen
// Dark, period pill, Übersicht/Transaktionen (active) tabs, transaction cards.
struct TransaktionenScreen: View {
    @Environment(AppRouter.self)    private var router
    @Environment(AppContainer.self) private var container
    @State private var vm: TransaktionenViewModel?

    @State private var selectedTab = NavTab.profile

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd. MMM yyyy"
        f.locale = Locale(identifier: "de_AT")
        return f
    }()

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.scoonDarker.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
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

                    Text("letzten 30 Tage")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Color.scoonDark)
                        .clipShape(Capsule())
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                    HStack(spacing: 0) {
                        TransTabButton(title: "Übersicht", isActive: false) {
                            router.navigateBack()
                        }
                        TransTabButton(title: "Transaktionen", isActive: true) {}
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    Text("Transaktionen")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                    if let vm {
                        if vm.isLoading {
                            ProgressView().tint(Color.scoonOrange)
                                .frame(maxWidth: .infinity).padding(.top, 40)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(vm.transactions) { transaction in
                                    TransactionCard(transaction: transaction, dateFormatter: Self.dateFormatter)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                        }
                    }

                    Spacer().frame(height: 100)
                }
            }

            NavBarView(selectedTab: $selectedTab)
        }
        .navigationBarHidden(true)
        .task {
            let viewModel = container.makeTransaktionenViewModel()
            vm = viewModel
            await viewModel.onAppear()
        }
    }
}

private struct TransactionCard: View {
    let transaction: Transaction
    let dateFormatter: DateFormatter

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(NSDecimalNumber(decimal: transaction.amount).stringValue) \(transaction.currency)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                Text(dateFormatter.string(from: transaction.date))
                    .font(.system(size: 13))
                    .foregroundColor(Color.scoonTextSecondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 8) {
                Text(transaction.status.rawValue)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(red: 0.85, green: 0.65, blue: 0.0))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(red: 0.85, green: 0.65, blue: 0.0).opacity(0.15))
                    .cornerRadius(6)
                Button(action: {}) {
                    Text("Zeig Details")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Color(red: 0.85, green: 0.65, blue: 0.0).opacity(0.3))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(16)
        .background(Color.scoonDark)
        .cornerRadius(14)
    }
}

private struct TransTabButton: View {
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
