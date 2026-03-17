import Foundation

protocol SpotRepositoryProtocol {
    func fetchSpots(filter: SpotFilter?) async throws -> [Spot]
    func fetchFavorites() async throws -> [Spot]
    func fetchNearbySpots() async throws -> [Spot]
    func toggleFavorite(spotID: UUID) async throws
    func createSpot(_ draft: SpotDraft) async throws -> Spot
}

/// Value type used when creating a new spot (no id yet — assigned by backend).
struct SpotDraft {
    let name:        String
    let location:    String
    let description: String
    let category:    SpotCategory
    let imageURLs:   [String]
}
