import SwiftUI

struct SegmentTabButton: View {
    let title: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 15, weight: isActive ? .semibold : .regular))
                    .foregroundColor(isActive ? Color.scoonOrange : Color.scoonTextSecondary)
                Rectangle()
                    .fill(isActive ? Color.scoonOrange : Color.clear)
                    .frame(height: 2)
                    .cornerRadius(1)
            }
        }
        .frame(maxWidth: .infinity)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isActive)
    }
}
