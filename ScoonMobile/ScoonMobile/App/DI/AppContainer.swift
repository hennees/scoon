import Foundation

/// Dependency injection root. Owns one instance of every repository
/// and vends pre-wired use cases and ViewModels.
///
/// Swap any `Mock*Repository` for a real implementation here —
/// no Domain or Presentation code needs to change.
@Observable
final class AppContainer {

    // MARK: – Repositories (singletons within the container)

    let spotRepository:        SpotRepositoryProtocol
    let userRepository:        UserRepositoryProtocol
    let transactionRepository: TransactionRepositoryProtocol
    let authRepository:        AuthRepositoryProtocol

    // MARK: – Init

    init(
        spotRepository:        SpotRepositoryProtocol        = MockSpotRepository(),
        userRepository:        UserRepositoryProtocol        = MockUserRepository(),
        transactionRepository: TransactionRepositoryProtocol = MockTransactionRepository(),
        authRepository:        AuthRepositoryProtocol        = MockAuthRepository()
    ) {
        self.spotRepository        = spotRepository
        self.userRepository        = userRepository
        self.transactionRepository = transactionRepository
        self.authRepository        = authRepository
    }

    // MARK: – Use Case factories (computed – same repo, new use-case wrapper each call)

    var fetchSpotsUseCase:       FetchSpotsUseCase       { FetchSpotsUseCase(repository: spotRepository) }
    var createSpotUseCase:       CreateSpotUseCase       { CreateSpotUseCase(repository: spotRepository) }
    var fetchFavoritesUseCase:   FetchFavoritesUseCase   { FetchFavoritesUseCase(repository: spotRepository) }
    var toggleFavoriteUseCase:   ToggleFavoriteUseCase   { ToggleFavoriteUseCase(repository: spotRepository) }
    var fetchProfileUseCase:     FetchUserProfileUseCase { FetchUserProfileUseCase(repository: userRepository) }
    var fetchInsightsUseCase:    FetchInsightsUseCase    { FetchInsightsUseCase(repository: userRepository) }
    var fetchTransactionsUseCase:FetchTransactionsUseCase{ FetchTransactionsUseCase(repository: transactionRepository) }

    // MARK: – ViewModel factories (new instance per screen push)

    func makeAuthViewModel()         -> AuthViewModel         { AuthViewModel(authRepository: authRepository) }
    func makeAddSpotViewModel()      -> AddSpotViewModel      { AddSpotViewModel(createSpot: createSpotUseCase) }
    func makeHomeViewModel()         -> HomeViewModel        { HomeViewModel(fetchSpots: fetchSpotsUseCase) }
    func makeFavoritesViewModel()    -> FavoritesViewModel   { FavoritesViewModel(fetchFavorites: fetchFavoritesUseCase, toggleFavorite: toggleFavoriteUseCase) }
    func makeProfileViewModel()      -> ProfileViewModel     { ProfileViewModel(fetchProfile: fetchProfileUseCase) }
    func makeInsightsViewModel()     -> InsightsViewModel    { InsightsViewModel(fetchInsights: fetchInsightsUseCase, fetchProfile: fetchProfileUseCase) }
    func makeEinnahmenViewModel()    -> EinnahmenViewModel   { EinnahmenViewModel(fetchTransactions: fetchTransactionsUseCase) }
    func makeTransaktionenViewModel()-> TransaktionenViewModel { TransaktionenViewModel(fetchTransactions: fetchTransactionsUseCase) }
}
