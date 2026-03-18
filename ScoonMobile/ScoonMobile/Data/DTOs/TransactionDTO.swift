import Foundation

struct TransactionDTO: Codable {
    let id:        String
    let amount:    Decimal
    let currency:  String?
    let status:    String?
    let createdAt: String?  // optional – not present in partial selects
}
