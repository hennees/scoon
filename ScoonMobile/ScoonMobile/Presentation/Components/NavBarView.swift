import SwiftUI

enum NavTab {
    case home, map, favorites, profile
}

struct NavBarView: View {
    @Environment(AppRouter.self) private var router

    private let items: [(icon: String, tab: NavTab)] = [
        ("house.fill",  .home),
        ("map.fill",    .map),
        ("heart.fill",  .favorites),
        ("person.fill", .profile),
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items, id: \.tab.hashValue) { item in
                NavBarItem(
                    systemIcon: item.icon,
                    isSelected: router.selectedTab == item.tab,
                    onTap:      { router.selectedTab = item.tab }
                )
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                // Adaptive blur layer — inherits the current color scheme
                Rectangle()
                    .fill(.ultraThinMaterial)

                // Adaptive tint: near-black in dark, near-white in light
                Rectangle()
                    .fill(Color.scoonNavBar.opacity(0.6))

                // Top separator
                VStack {
                    Rectangle()
                        .fill(Color.primary.opacity(0.08))
                        .frame(height: 0.5)
                    Spacer()
                }
            }
            .clipShape(.rect(topLeadingRadius: 24, bottomLeadingRadius: 0,
                             bottomTrailingRadius: 0, topTrailingRadius: 24))
            .ignoresSafeArea(.container, edges: .bottom)
        )
    }
}

private struct NavBarItem: View {
    let systemIcon: String
    let isSelected: Bool
    let onTap:      () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 5) {
                ZStack {
                    // Active pill background
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.scoonOrange.opacity(isSelected ? 0.18 : 0))
                        .frame(width: 50, height: 34)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)

                    Image(systemName: systemIcon)
                        .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                        .foregroundStyle(isSelected ? Color.scoonOrange : Color.primary.opacity(0.35))
                        .scaleEffect(isSelected ? 1.08 : 1.0)
                        .animation(.spring(response: 0.28, dampingFraction: 0.65), value: isSelected)
                }

                // Active dot
                Circle()
                    .fill(Color.scoonOrange)
                    .frame(width: 4, height: 4)
                    .opacity(isSelected ? 1 : 0)
                    .scaleEffect(isSelected ? 1 : 0.1)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}
