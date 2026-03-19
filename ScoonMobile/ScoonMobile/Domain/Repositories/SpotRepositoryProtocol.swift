import Foundation

protocol SpotRepositoryProtocol {
    func fetchSpots(filter: SpotFilter?) async throws -> [Spot]
    func fetchFavorites() async throws -> [Spot]
    func fetchNearbySpots(latitude: Double, longitude: Double, radiusMeters: Double) async throws -> [Spot]
    func toggleFavorite(spotID: UUID) async throws
    func createSpot(_ draft: SpotDraft) async throws -> Spot
    func addPhotosToSpot(spotID: UUID, imageURLs: [String]) async throws
    func fetchSpotsByCreator(userId: UUID) async throws -> [Spot]
}

/// Value type used when creating a new spot (no id yet — assigned by backend).
struct SpotDraft {
    let name:        String
    let location:    String
    let description: String
    let category:    SpotCategory
    let imageURLs:   [String]
    let latitude:    Double?
    let longitude:   Double?
}
