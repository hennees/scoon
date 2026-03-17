import Foundation

protocol TransactionRepositoryProtocol {
    func fetchTransactions() async throws -> [Transaction]
    func fetchPendingPayout() async throws -> Decimal
}
