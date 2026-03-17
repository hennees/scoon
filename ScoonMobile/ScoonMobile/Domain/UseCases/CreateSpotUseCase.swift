import Foundation

struct CreateSpotUseCase {
    private let repository: SpotRepositoryProtocol

    init(repository: SpotRepositoryProtocol) {
        self.repository = repository
    }

    func execute(_ draft: SpotDraft) async throws -> Spot {
        try await repository.createSpot(draft)
    }
}
