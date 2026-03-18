import SwiftUI

@Observable
final class AppRouter {

    // MARK: – Auth state

    var isLoggedIn: Bool = false

    // MARK: – Auth navigation (WelcomeScreen → Login / SignUp)

    var authPath = NavigationPath()

    // MARK: – Main app: selected tab

    var selectedTab: NavTab = .home

    // MARK: – Per-tab navigation paths (independent stacks)

    var homePath      = NavigationPath()
    var mapPath       = NavigationPath()
    var favoritesPath = NavigationPath()
    var profilePath   = NavigationPath()

    // MARK: – Navigation helpers

    func navigate(to route: AppRoute) {
        guard isLoggedIn else {
            authPath.append(route)
            return
        }
        switch selectedTab {
        case .home:      homePath.append(route)
        case .map:       mapPath.append(route)
        case .favorites: favoritesPath.append(route)
        case .profile:   profilePath.append(route)
        }
    }

    func navigateBack() {
        switch selectedTab {
        case .home:      if !homePath.isEmpty      { homePath.removeLast() }
        case .map:       if !mapPath.isEmpty       { mapPath.removeLast() }
        case .favorites: if !favoritesPath.isEmpty { favoritesPath.removeLast() }
        case .profile:   if !profilePath.isEmpty   { profilePath.removeLast() }
        }
    }

    func switchTab(to tab: NavTab) {
        selectedTab = tab
    }

    /// Navigate to the home tab and clear its stack — used by tapping the scoon logo.
    func switchToHome() {
        homePath = NavigationPath()
        selectedTab = .home
    }

    // MARK: – Auth transitions

    /// Called after successful login / sign-up.
    func login() {
        authPath = NavigationPath()
        isLoggedIn = true
        selectedTab = .home
    }

    /// Called after sign-out.
    func logout() {
        isLoggedIn = false
        homePath      = NavigationPath()
        mapPath       = NavigationPath()
        favoritesPath = NavigationPath()
        profilePath   = NavigationPath()
    }

    // MARK: – Legacy stubs (used in some screens, kept for compatibility)

    /// No-op — per-tab paths make this unnecessary.
    func markHomeDepth() {}

    /// Pop everything in the current auth path (used before login()).
    func navigateToRoot() {
        if isLoggedIn {
            switch selectedTab {
            case .home:      homePath = NavigationPath()
            case .map:       mapPath = NavigationPath()
            case .favorites: favoritesPath = NavigationPath()
            case .profile:   profilePath = NavigationPath()
            }
        } else {
            authPath = NavigationPath()
        }
    }
}
