import Foundation

final class MockTransactionRepository: TransactionRepositoryProtocol {

    var simulatedDelay: Double = 0.3

    private let transactions: [Transaction] = [
        Transaction(
            id:       UUID(),
            amount:   Decimal(60.00),
            currency: "EUR",
            status:   .paid,
            date:     Calendar.current.date(byAdding: .day, value: -7,  to: Date()) ?? Date()
        ),
        Transaction(
            id:       UUID(),
            amount:   Decimal(32.00),
            currency: "EUR",
            status:   .paid,
            date:     Calendar.current.date(byAdding: .day, value: -16, to: Date()) ?? Date()
        ),
    ]

    func fetchTransactions() async throws -> [Transaction] {
        try await Task.sleep(for: .seconds(simulatedDelay))
        return transactions
    }

    func fetchPendingPayout() async throws -> Decimal {
        try await Task.sleep(for: .seconds(simulatedDelay))
        return Decimal(0.00)
    }
}
