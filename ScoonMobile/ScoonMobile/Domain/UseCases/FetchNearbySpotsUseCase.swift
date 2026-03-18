import Foundation

struct FetchNearbySpotsUseCase {
    private let repository: SpotRepositoryProtocol

    init(repository: SpotRepositoryProtocol) {
        self.repository = repository
    }

    func execute(latitude: Double, longitude: Double, radiusMeters: Double = 2500) async throws -> [Spot] {
        try await repository.fetchNearbySpots(
            latitude: latitude,
            longitude: longitude,
            radiusMeters: radiusMeters
        )
    }
}
