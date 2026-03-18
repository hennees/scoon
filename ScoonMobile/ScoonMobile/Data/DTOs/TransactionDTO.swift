import Foundation

struct TransactionDTO: Codable {
    let id:         String
    let amount:     Decimal
    let currency:   String
    let status:     String
    let created_at: String  // Supabase column name (ISO 8601)
}
