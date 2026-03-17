import SwiftUI

struct ContentView: View {
    @State private var showSplash = true
    @State private var router     = AppRouter()

    @Environment(AppContainer.self) private var container

    var body: some View {
        Group {
            if showSplash {
                SplashScreen()
                    .transition(.opacity)
            } else {
                NavigationStack(path: $router.path) {
                    WelcomeScreen()
                        .navigationDestination(for: AppRoute.self) { route in
                            routeView(for: route)
                        }
                }
                .environment(router)
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.6), value: showSplash)
        .task {
            try? await Task.sleep(for: .seconds(2.5))
            showSplash = false
        }
    }

    @ViewBuilder
    private func routeView(for route: AppRoute) -> some View {
        switch route {
        case .welcome:           WelcomeScreen()
        case .signUpSocial:      SignUpSocialScreen()
        case .signUpForm:        SignUpFormScreen()
        case .signUpEmail:       SignUpEmailScreen()
        case .login:             LoginScreen()
        case .home:              HomeScreen()
        case .placeInfo:         PlaceInfoScreen()
        case .ortAuswahl:        OrtAuswahlScreen()
        case .kartenansicht:     KartenansichtScreen()
        case .kartenansichtDetail: KartenansichtDetailScreen()
        case .favorites:         FavoritesScreen()
        case .settings:          SettingsScreen()
        case .addPhotoSpot:      AddPhotoSpotScreen()
        case .insights:          InsightsScreen()
        case .profile:           ProfileScreen()
        case .einnahmen:         EinnahmenScreen()
        case .ortSuche:          OrtSucheScreen()
        case .transaktionen:     TransaktionenScreen()
        }
    }
}

#Preview {
    ContentView()
        .environment(AppContainer())
}
