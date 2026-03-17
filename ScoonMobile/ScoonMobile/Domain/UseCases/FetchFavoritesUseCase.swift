import Foundation

struct FetchFavoritesUseCase {
    private let repository: SpotRepositoryProtocol

    init(repository: SpotRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [Spot] {
        try await repository.fetchFavorites()
    }
}

struct ToggleFavoriteUseCase {
    private let repository: SpotRepositoryProtocol

    init(repository: SpotRepositoryProtocol) {
        self.repository = repository
    }

    func execute(spotID: UUID) async throws {
        try await repository.toggleFavorite(spotID: spotID)
    }
}
