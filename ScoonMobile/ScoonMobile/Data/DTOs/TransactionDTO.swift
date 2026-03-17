import Foundation

struct TransactionDTO: Codable {
    let id:       String
    let amount:   Double
    let currency: String
    let status:   String
    let date:     String   // ISO 8601 string from API
}
