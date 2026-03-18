import Foundation

final class RemoteTransactionRepository: TransactionRepositoryProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func fetchTransactions() async throws -> [Transaction] {
        let request = APIRequest(
            method: .get,
            path: APIEndpoints.Creator.transactions,
            queryItems: [
                URLQueryItem(name: "select", value: "*"),
                URLQueryItem(name: "order",  value: "created_at.desc")
            ],
            requiresAuth: true
        )
        let dtos = try await apiClient.send(request, as: [TransactionDTO].self)
        return dtos.map(TransactionMapper.map)
    }

    func fetchPendingPayout() async throws -> Decimal {
        // Compute pending payout from transactions with status=pending
        let request = APIRequest(
            method: .get,
            path: APIEndpoints.Creator.transactions,
            queryItems: [
                URLQueryItem(name: "select", value: "amount"),
                URLQueryItem(name: "status", value: "eq.pending")
            ],
            requiresAuth: true
        )
        let dtos = try await apiClient.send(request, as: [TransactionDTO].self)
        return dtos.reduce(Decimal(0)) { $0 + $1.amount }
    }
}
