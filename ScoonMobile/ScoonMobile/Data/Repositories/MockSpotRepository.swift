import Foundation

/// Mock implementation of SpotRepositoryProtocol.
/// Returns hardcoded Graz spots. Swap for a real implementation (Supabase, REST API)
/// without touching any Domain or Presentation code.
final class MockSpotRepository: SpotRepositoryProtocol {

    // Simulated network delay (seconds) — useful for testing loading states.
    var simulatedDelay: Double = 0.4

    private var spots: [Spot] = [
        Spot(
            id:          UUID(),
            name:        "Murinsel",
            location:    "Graz, Austria",
            rating:      4.8,
            imageURL:    "https://www.figma.com/api/mcp/asset/4c92510c-b715-4ba9-b560-fb389c098aad",
            isFavorite:  false,
            description: "Die Murinsel ist ein architektonisches Highlight inmitten der Stadt Graz – eine schwimmende Plattform auf der Mur, die modernes Design mit urbanem Erlebnis vereint.",
            viewCount:   1420,
            likeCount:   135,
            saveCount:   67,
            distance:    nil,
            category:    .architecture
        ),
        Spot(
            id:          UUID(),
            name:        "Stadtpark",
            location:    "Graz, Austria",
            rating:      4.8,
            imageURL:    "https://www.figma.com/api/mcp/asset/5c2eff61-1398-46d1-b246-219c24477e45",
            isFavorite:  true,
            description: "Ruhige Grünanlage im Herzen der Stadt mit wunderschönen alten Bäumen.",
            viewCount:   823,
            likeCount:   425,
            saveCount:   167,
            distance:    nil,
            category:    .parkGarden
        ),
        Spot(
            id:          UUID(),
            name:        "Schlossberg",
            location:    "Graz, Austria",
            rating:      4.8,
            imageURL:    "https://www.figma.com/api/mcp/asset/ad0ee92b-65cd-4acb-804a-51f27ccd4685",
            isFavorite:  false,
            description: "Der markante Hausberg von Graz mit Uhrturm und Panoramablick über die Stadt.",
            viewCount:   2100,
            likeCount:   890,
            saveCount:   340,
            distance:    nil,
            category:    .urban
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

    func fetchNearbySpots() async throws -> [Spot] {
        try await Task.sleep(for: .seconds(simulatedDelay))
        return spots.map { spot in
            var s = spot
            // Attach mock distances for nearby context
            _ = s  // Spot is a struct; distance is let — in real app, API provides it
            return Spot(id: spot.id, name: spot.name, location: spot.location,
                        rating: spot.rating, imageURL: spot.imageURL, isFavorite: spot.isFavorite,
                        description: spot.description, viewCount: spot.viewCount,
                        likeCount: spot.likeCount, saveCount: spot.saveCount,
                        distance: ["0.3 km", "0.7 km", "1.2 km"].randomElement(),
                        category: spot.category)
        }
    }

    func createSpot(_ draft: SpotDraft) async throws -> Spot {
        try await Task.sleep(for: .seconds(simulatedDelay))
        let newSpot = Spot(
            id:          UUID(),
            name:        draft.name,
            location:    draft.location,
            rating:      0.0,
            imageURL:    draft.imageURLs.first ?? "",
            isFavorite:  false,
            description: draft.description,
            viewCount:   0,
            likeCount:   0,
            saveCount:   0,
            distance:    nil,
            category:    draft.category
        )
        spots.append(newSpot)
        return newSpot
    }

    func toggleFavorite(spotID: UUID) async throws {
        try await Task.sleep(for: .seconds(simulatedDelay))
        guard let index = spots.firstIndex(where: { $0.id == spotID }) else { return }
        spots[index] = Spot(
            id: spots[index].id, name: spots[index].name, location: spots[index].location,
            rating: spots[index].rating, imageURL: spots[index].imageURL,
            isFavorite: !spots[index].isFavorite,
            description: spots[index].description, viewCount: spots[index].viewCount,
            likeCount: spots[index].likeCount, saveCount: spots[index].saveCount,
            distance: spots[index].distance, category: spots[index].category
        )
    }
}
