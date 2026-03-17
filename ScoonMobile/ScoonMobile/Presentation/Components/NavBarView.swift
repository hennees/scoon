import SwiftUI

enum NavTab {
    case home, map, favorites, profile
}

struct NavBarView: View {
    @Binding var selectedTab: NavTab
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
                    tab: item.tab,
                    selected: $selectedTab,
                    onNavigate: { router.switchTab(to: item.tab) }
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .padding(.bottom, 10)
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                Color.scoonNavBar
                // Subtle top separator line
                VStack {
                    Rectangle()
                        .fill(Color.white.opacity(0.07))
                        .frame(height: 1)
                    Spacer()
                }
            }
            .clipShape(.rect(topLeadingRadius: 22, bottomLeadingRadius: 0,
                             bottomTrailingRadius: 0, topTrailingRadius: 22))
            .ignoresSafeArea(.container, edges: .bottom)
        )
    }
}

private struct NavBarItem: View {
    let systemIcon: String
    let tab:        NavTab
    @Binding var selected: NavTab
    let onNavigate: () -> Void

    var isSelected: Bool { selected == tab }

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selected = tab
            }
            onNavigate()
        }) {
            ZStack {
                // Active pill background
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.scoonOrange.opacity(isSelected ? 0.18 : 0))
                    .frame(width: 54, height: 40)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)

                Image(systemName: systemIcon)
                    .font(.system(size: 21, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(
                        isSelected
                            ? Color.scoonOrange
                            : Color.white.opacity(0.38)
                    )
                    .scaleEffect(isSelected ? 1.12 : 1.0)
                    .animation(.spring(response: 0.25, dampingFraction: 0.65), value: isSelected)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}
