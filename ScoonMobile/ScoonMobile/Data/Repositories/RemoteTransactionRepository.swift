import Foundation

private struct PendingPayoutDTO: Decodable {
    let amount: Double
}

final class RemoteTransactionRepository: TransactionRepositoryProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func fetchTransactions() async throws -> [Transaction] {
        let request = APIRequest(method: .get, path: APIEndpoints.Creator.transactions, requiresAuth: true)
        let dtos = try await apiClient.send(request, as: [TransactionDTO].self)
        return dtos.map(TransactionMapper.map)
    }

    func fetchPendingPayout() async throws -> Decimal {
        let request = APIRequest(method: .get, path: APIEndpoints.Creator.pendingPayout, requiresAuth: true)
        let dto = try await apiClient.send(request, as: PendingPayoutDTO.self)
        return Decimal(dto.amount)
    }
}
