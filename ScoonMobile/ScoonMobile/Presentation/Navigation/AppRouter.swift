import SwiftUI

/// Centralized navigation manager. Injected into the SwiftUI environment once
/// at the root and consumed by any screen via @Environment(AppRouter.self).
/// Eliminates the need to thread @Binding var path through every screen initializer.
@Observable
final class AppRouter {
    var path = NavigationPath()

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
}
