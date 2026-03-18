import SwiftUI

extension TransactionStatus {
    var statusColor: Color {
        switch self {
        case .paid:    return Color(red: 0.2,  green: 0.8,  blue: 0.4)
        case .pending: return Color(red: 0.95, green: 0.7,  blue: 0.0)
        case .failed:  return Color.red
        }
    }
    var statusIcon: String {
        switch self {
        case .paid:    return "checkmark.circle.fill"
        case .pending: return "clock.fill"
        case .failed:  return "xmark.circle.fill"
        }
    }
}
