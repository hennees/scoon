import Foundation

enum TransactionMapper {
    static func map(_ dto: TransactionDTO) -> Transaction {
        let isoFormatter = ISO8601DateFormatter()
        let date = dto.createdAt.flatMap { isoFormatter.date(from: $0) } ?? Date()
        let status = dto.status.flatMap { TransactionStatus(rawValue: $0) } ?? .pending

        return Transaction(
            id:       UUID(uuidString: dto.id) ?? UUID(),
            amount:   dto.amount,
            currency: dto.currency ?? "EUR",
            status:   status,
            date:     date
        )
    }
}
