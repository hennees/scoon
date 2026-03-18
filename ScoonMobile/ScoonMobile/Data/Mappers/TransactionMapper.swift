import Foundation

enum TransactionMapper {
    static func map(_ dto: TransactionDTO) -> Transaction {
        let isoFormatter = ISO8601DateFormatter()
        let date = isoFormatter.date(from: dto.created_at) ?? Date()
        let status = TransactionStatus(rawValue: dto.status) ?? .pending

        return Transaction(
            id:       UUID(uuidString: dto.id) ?? UUID(),
            amount:   dto.amount,
            currency: dto.currency,
            status:   status,
            date:     date
        )
    }
}
