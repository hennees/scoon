import SwiftUI

struct ContentView: View {
    @State private var showSplash    = true
    @State private var showOnboarding = false
    @State private var router        = AppRouter()

    @Environment(AppContainer.self) private var container

    @AppStorage("isDarkMode")         private var isDarkMode:         Bool = true
    @AppStorage("hasSeenOnboarding")  private var hasSeenOnboarding:  Bool = false

    var body: some View {
        Group {
            if showSplash {
                SplashScreen()
                    .transition(.opacity)
            } else if showOnboarding {
                OnboardingScreen {
                    hasSeenOnboarding = true
                    withAnimation(.easeInOut(duration: 0.45)) { showOnboarding = false }
                }
                .transition(.opacity)
            } else if router.isLoggedIn {
                MainTabView()
                    .environment(router)
                    .transition(.opacity)
            } else {
                @Bindable var r = router
                NavigationStack(path: $r.authPath) {
                    WelcomeScreen()
                        .navigationDestination(for: AppRoute.self) { authRouteView(for: $0) }
                }
                .environment(router)
                .transition(.opacity)
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .animation(.easeInOut(duration: 0.45), value: showSplash)
        .animation(.easeInOut(duration: 0.45), value: showOnboarding)
        .animation(.easeInOut(duration: 0.35), value: router.isLoggedIn)
        .task {
            async let authCheck = container.authRepository.currentUser()
            try? await Task.sleep(for: .seconds(2.5))
            if await authCheck != nil { router.isLoggedIn = true }
            showSplash = false
            if !hasSeenOnboarding { showOnboarding = true }
        }
    }

    @ViewBuilder
    private func authRouteView(for route: AppRoute) -> some View {
        switch route {
        case .login:        LoginScreen()
        case .signUpSocial: SignUpSocialScreen()
        case .signUpForm:   SignUpFormScreen()
        case .signUpEmail:  SignUpEmailScreen()
        default:            EmptyView()
        }
    }
}

// MARK: – Main tab container

struct MainTabView: View {
    @Environment(AppRouter.self)    private var router
    @Environment(AppContainer.self) private var container

    var body: some View {
        @Bindable var r = router

        ZStack(alignment: .bottom) {
            TabView(selection: $r.selectedTab) {
                NavigationStack(path: $r.homePath) {
                    HomeScreen()
                        .navigationDestination(for: AppRoute.self) { tabRouteView(for: $0) }
                }
                .tag(NavTab.home)

                NavigationStack(path: $r.mapPath) {
                    KartenansichtScreen()
                        .navigationDestination(for: AppRoute.self) { tabRouteView(for: $0) }
                }
                .tag(NavTab.map)

                NavigationStack(path: $r.favoritesPath) {
                    FavoritesScreen()
                        .navigationDestination(for: AppRoute.self) { tabRouteView(for: $0) }
                }
                .tag(NavTab.favorites)

                NavigationStack(path: $r.profilePath) {
                    ProfileScreen()
                        .navigationDestination(for: AppRoute.self) { tabRouteView(for: $0) }
                }
                .tag(NavTab.profile)
            }
            .toolbar(.hidden, for: .tabBar)

            NavBarView()
        }
    }

    @ViewBuilder
    private func tabRouteView(for route: AppRoute) -> some View {
        switch route {
        case .placeInfo(let spot):      PlaceInfoScreen(spot: spot)
        case .settings:                 SettingsScreen()
        case .addPhotoSpot:             AddPhotoSpotScreen()
        case .kartenansicht:            KartenansichtScreen()
        case .kartenansichtDetail:      KartenansichtScreen()
        case .insights:                 InsightsScreen()
        case .einnahmen:                EinnahmenScreen()
        case .transaktionen:            TransaktionenScreen()
        case .profile:                  ProfileScreen()
        case .ortAuswahl:               OrtAuswahlScreen()
        case .ortSuche:                 OrtSucheScreen()
        case .privacyPolicy:            LegalScreen(title: "Datenschutz",        content: LegalContent.privacy)
        case .termsOfService:           LegalScreen(title: "Nutzungsbedingungen", content: LegalContent.terms)
        case .imprint:                  LegalScreen(title: "Impressum",           content: LegalContent.imprint)
        case .editProfile(let user):    EditProfileScreen(user: user)
        case .addPhotoToSpot(let spot): AddPhotoToSpotScreen(spot: spot)
        case .becomeCreator:            BecomeCreatorScreen()
        default:                        EmptyView()
        }
    }
}

#Preview {
    ContentView()
        .environment(AppContainer())
}
