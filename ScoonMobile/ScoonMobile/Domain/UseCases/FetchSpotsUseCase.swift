import Foundation

struct FetchSpotsUseCase {
    private let repository: SpotRepositoryProtocol

    init(repository: SpotRepositoryProtocol) {
        self.repository = repository
    }

    func execute(filter: SpotFilter? = nil) async throws -> [Spot] {
        try await repository.fetchSpots(filter: filter)
    }
}
