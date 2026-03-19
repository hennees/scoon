import Foundation

final class MockSpotRepository: SpotRepositoryProtocol {

    var simulatedDelay: Double = 0.4

    /// A stable UUID representing the mock logged-in user — used to simulate "Meine Orte".
    static let mockUserID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!

    private var spots: [Spot] = [
        Spot(
            id: UUID(), name: "Murinsel", location: "Graz, Austria",
            rating: 4.8,
            imageURL: "https://www.figma.com/api/mcp/asset/4c92510c-b715-4ba9-b560-fb389c098aad",
            isFavorite: false,
            description: "Die Murinsel ist ein architektonisches Highlight inmitten der Stadt Graz – eine schwimmende Plattform auf der Mur.",
            viewCount: 1420, likeCount: 135, saveCount: 67,
            distance: nil, category: .architecture,
            latitude: 47.0708, longitude: 15.4386,
            creatorId: UUID(uuidString: "00000000-0000-0000-0000-000000000001")
        ),
        Spot(
            id: UUID(), name: "Stadtpark", location: "Graz, Austria",
            rating: 4.8,
            imageURL: "https://www.figma.com/api/mcp/asset/5c2eff61-1398-46d1-b246-219c24477e45",
            isFavorite: true,
            description: "Ruhige Grünanlage im Herzen der Stadt mit wunderschönen alten Bäumen.",
            viewCount: 823, likeCount: 425, saveCount: 167,
            distance: nil, category: .parkGarden,
            latitude: 47.0749, longitude: 15.4415,
            creatorId: nil
        ),
        Spot(
            id: UUID(), name: "Schlossberg", location: "Graz, Austria",
            rating: 4.8,
            imageURL: "https://www.figma.com/api/mcp/asset/ad0ee92b-65cd-4acb-804a-51f27ccd4685",
            isFavorite: false,
            description: "Der markante Hausberg von Graz mit Uhrturm und Panoramablick über die Stadt.",
            viewCount: 2100, likeCount: 890, saveCount: 340,
            distance: nil, category: .urban,
            latitude: 47.0726, longitude: 15.4387,
            creatorId: nil
        ),
    ]

    func fetchSpots(filter: SpotFilter?) async throws -> [Spot] {
        try await Task.sleep(for: .seconds(simulatedDelay))
        return spots
    }

    func fetchFavorites() async throws -> [Spot] {
        try await Task.sleep(for: .seconds(simulatedDelay))
        return spots.filter { $0.isFavorite }
    }

    func fetchNearbySpots(latitude: Double, longitude: Double, radiusMeters: Double) async throws -> [Spot] {
        try await Task.sleep(for: .seconds(simulatedDelay))
        let mockDistances = ["0.3 km", "0.7 km", "1.2 km"]
        return spots.enumerated().map { i, spot in
            Spot(id: spot.id, name: spot.name, location: spot.location,
                 rating: spot.rating, imageURL: spot.imageURL, isFavorite: spot.isFavorite,
                 description: spot.description, viewCount: spot.viewCount,
                 likeCount: spot.likeCount, saveCount: spot.saveCount,
                 distance: mockDistances[i % mockDistances.count],
                 category: spot.category,
                 latitude: spot.latitude, longitude: spot.longitude,
                 creatorId: spot.creatorId)
        }
    }

    func createSpot(_ draft: SpotDraft) async throws -> Spot {
        try await Task.sleep(for: .seconds(simulatedDelay))
        let newSpot = Spot(
            id: UUID(), name: draft.name, location: draft.location,
            rating: 0.0, imageURL: draft.imageURLs.first ?? "",
            isFavorite: false, description: draft.description,
            viewCount: 0, likeCount: 0, saveCount: 0,
            distance: nil, category: draft.category,
            latitude: draft.latitude, longitude: draft.longitude,
            creatorId: MockSpotRepository.mockUserID
        )
        spots.append(newSpot)
        return newSpot
    }

    func toggleFavorite(spotID: UUID) async throws {
        try await Task.sleep(for: .seconds(simulatedDelay))
        guard let i = spots.firstIndex(where: { $0.id == spotID }) else { return }
        let s = spots[i]
        spots[i] = Spot(id: s.id, name: s.name, location: s.location,
                        rating: s.rating, imageURL: s.imageURL, isFavorite: !s.isFavorite,
                        description: s.description, viewCount: s.viewCount,
                        likeCount: s.likeCount, saveCount: s.saveCount,
                        distance: s.distance, category: s.category,
                        latitude: s.latitude, longitude: s.longitude,
                        creatorId: s.creatorId)
    }

    func addPhotosToSpot(spotID: UUID, imageURLs: [String]) async throws {
        try await Task.sleep(for: .seconds(simulatedDelay))
        // Mock: no-op — photos are tracked in-memory via SpotPhoto model
    }

    func fetchSpotsByCreator(userId: UUID) async throws -> [Spot] {
        try await Task.sleep(for: .seconds(simulatedDelay))
        return spots.filter { $0.creatorId == userId }
    }
}
