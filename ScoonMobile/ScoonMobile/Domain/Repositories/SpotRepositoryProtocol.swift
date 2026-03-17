import Foundation

protocol SpotRepositoryProtocol {
    func fetchSpots(filter: SpotFilter?) async throws -> [Spot]
    func fetchFavorites() async throws -> [Spot]
    func fetchNearbySpots() async throws -> [Spot]
    func toggleFavorite(spotID: UUID) async throws
}
