import Foundation

/// Earnings transaction entity. Replaces the private Transaction struct
/// previously defined inside TransaktionenScreen.swift.
struct Transaction: Identifiable, Hashable {
    let id:       UUID
    let amount:   Decimal
    let currency: String
    let status:   TransactionStatus
    let date:     Date
}

enum TransactionStatus: String, Hashable, CaseIterable {
    case paid    = "paid"
    case pending = "pending"
    case failed  = "failed"

    var displayLabel: String {
        switch self {
        case .paid:    return "Bezahlt"
        case .pending: return "Ausstehend"
        case .failed:  return "Fehlgeschlagen"
        }
    }

    var displayColor: String {
        switch self {
        case .paid:    return "amber"
        case .pending: return "orange"
        case .failed:  return "red"
        }
    }
}

/// Aggregated insights summary for the creator dashboard.
struct InsightsSummary: Hashable {
    let totalViews:    Int
    let avgViewsPerSpot: Int
    let avgLikesPerSpot: Int
    let avgSavesPerSpot: Int
}
