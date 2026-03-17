import Foundation

struct FetchTransactionsUseCase {
    private let repository: TransactionRepositoryProtocol

    init(repository: TransactionRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> (transactions: [Transaction], pendingPayout: Decimal) {
        async let transactions  = repository.fetchTransactions()
        async let pendingPayout = repository.fetchPendingPayout()
        return try await (transactions, pendingPayout)
    }
}
