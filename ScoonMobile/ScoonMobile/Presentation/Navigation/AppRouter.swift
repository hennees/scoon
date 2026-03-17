import SwiftUI

/// Centralized navigation manager. Injected into the SwiftUI environment once
/// at the root and consumed by any screen via @Environment(AppRouter.self).
/// Eliminates the need to thread @Binding var path through every screen initializer.
@Observable
final class AppRouter {
    var path = NavigationPath()

    /// Depth of the path when HomeScreen first appears.
    /// Used by switchTab to always pop back to the home level.
    private var homeDepth: Int = 0

    func navigate(to route: AppRoute) {
        path.append(route)
    }

    func navigateBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func navigateToRoot() {
        path.removeLast(path.count)
    }

    /// Replace the current screen without adding to the stack.
    func replace(with route: AppRoute) {
        if !path.isEmpty { path.removeLast() }
        path.append(route)
    }

    /// Call once when HomeScreen appears to record the stack depth at home level.
    func markHomeDepth() {
        homeDepth = path.count
    }

    /// Switch to a main tab. Pops back to the home level first, then
    /// pushes the tab's route (except .home which is already at that depth).
    func switchTab(to tab: NavTab) {
        while path.count > homeDepth {
            path.removeLast()
        }
        switch tab {
        case .home:      break
        case .map:       path.append(AppRoute.kartenansicht)
        case .favorites: path.append(AppRoute.favorites)
        case .profile:   path.append(AppRoute.profile)
        }
    }
}
