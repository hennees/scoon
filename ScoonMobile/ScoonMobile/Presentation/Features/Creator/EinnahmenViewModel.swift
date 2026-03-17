import Foundation

@Observable
final class EinnahmenViewModel {
    private(set) var transactions:  [Transaction] = []
    private(set) var pendingPayout: Decimal       = 0
    private(set) var isLoading:     Bool          = false
    private(set) var error:         String?

    private let fetchTransactions: FetchTransactionsUseCase

    init(fetchTransactions: FetchTransactionsUseCase) {
        self.fetchTransactions = fetchTransactions
    }

    func onAppear() async {
        guard transactions.isEmpty else { return }
        isLoading = true
        error = nil
        do {
            let result   = try await fetchTransactions.execute()
            transactions = result.transactions
            pendingPayout = result.pendingPayout
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
