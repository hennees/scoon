import Foundation

enum DataSourceMode {
    case mock
    case remote
}

/// Dependency injection root. Owns one instance of every repository
/// and vends pre-wired use cases and ViewModels.
///
/// To switch to Supabase: set SUPABASE_URL + SUPABASE_ANON_KEY in the
/// Xcode scheme environment variables and set SCOON_USE_REMOTE_DATA=true.
@Observable
final class AppContainer {

    // MARK: – Repositories

    let spotRepository:        SpotRepositoryProtocol
    let userRepository:        UserRepositoryProtocol
    let transactionRepository: TransactionRepositoryProtocol
    let authRepository:        AuthRepositoryProtocol

    // MARK: – Init

    init(mode: DataSourceMode = AppEnvironment.current.useRemoteData ? .remote : .mock) {
        switch mode {
        case .mock:
            spotRepository        = MockSpotRepository()
            userRepository        = MockUserRepository()
            transactionRepository = MockTransactionRepository()
            authRepository        = MockAuthRepository()

        case .remote:
            let env = AppEnvironment.current

            guard let baseURL = env.apiBaseURL, let anonKey = env.supabaseAnonKey else {
                // Fallback to mock if config is missing
                spotRepository        = MockSpotRepository()
                userRepository        = MockUserRepository()
                transactionRepository = MockTransactionRepository()
                authRepository        = MockAuthRepository()
                return
            }

            let sessionStore = AuthSessionStore()
            let apiClient    = APIClient(
                baseURL:         baseURL,
                sessionStore:    sessionStore,
                supabaseAnonKey: anonKey
            )

            spotRepository        = RemoteSpotRepository(apiClient: apiClient, sessionStore: sessionStore)
            userRepository        = RemoteUserRepository(apiClient: apiClient)
            transactionRepository = RemoteTransactionRepository(apiClient: apiClient)
            authRepository        = RemoteAuthRepository(
                apiClient:    apiClient,
                sessionStore: sessionStore,
                supabaseURL:  baseURL.absoluteString
            )
        }
    }

    // MARK: – Use Case factories

    var fetchSpotsUseCase:        FetchSpotsUseCase        { FetchSpotsUseCase(repository: spotRepository) }
    var createSpotUseCase:        CreateSpotUseCase        { CreateSpotUseCase(repository: spotRepository) }
    var fetchFavoritesUseCase:    FetchFavoritesUseCase    { FetchFavoritesUseCase(repository: spotRepository) }
    var toggleFavoriteUseCase:    ToggleFavoriteUseCase    { ToggleFavoriteUseCase(repository: spotRepository) }
    var fetchProfileUseCase:      FetchUserProfileUseCase  { FetchUserProfileUseCase(repository: userRepository) }
    var fetchInsightsUseCase:     FetchInsightsUseCase     { FetchInsightsUseCase(repository: userRepository) }
    var fetchTransactionsUseCase: FetchTransactionsUseCase { FetchTransactionsUseCase(repository: transactionRepository) }

    // MARK: – ViewModel factories

    func makeAuthViewModel()          -> AuthViewModel          { AuthViewModel(authRepository: authRepository) }
    func makeAddSpotViewModel()       -> AddSpotViewModel       { AddSpotViewModel(createSpot: createSpotUseCase) }
    func makeHomeViewModel()          -> HomeViewModel          { HomeViewModel(fetchSpots: fetchSpotsUseCase) }
    func makeFavoritesViewModel()     -> FavoritesViewModel     { FavoritesViewModel(fetchFavorites: fetchFavoritesUseCase, toggleFavorite: toggleFavoriteUseCase) }
    func makeProfileViewModel()       -> ProfileViewModel       { ProfileViewModel(fetchProfile: fetchProfileUseCase) }
    func makeInsightsViewModel()      -> InsightsViewModel      { InsightsViewModel(fetchInsights: fetchInsightsUseCase, fetchProfile: fetchProfileUseCase) }
    func makeEinnahmenViewModel()     -> EinnahmenViewModel     { EinnahmenViewModel(fetchTransactions: fetchTransactionsUseCase) }
    func makeTransaktionenViewModel() -> TransaktionenViewModel { TransaktionenViewModel(fetchTransactions: fetchTransactionsUseCase) }
}
