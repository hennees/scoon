import Foundation

private struct CreateSpotPayload: Encodable {
    let name:        String
    let location:    String
    let description: String
    let category:    String
    let imageUrl:    String
    let latitude:    Double?
    let longitude:   Double?
}

private struct FavoritePayload: Encodable {
    let userId: String
    let spotId: String
}

final class RemoteSpotRepository: SpotRepositoryProtocol {
    private let apiClient:    APIClientProtocol
    private let sessionStore: AuthSessionStore

    init(apiClient: APIClientProtocol, sessionStore: AuthSessionStore) {
        self.apiClient    = apiClient
        self.sessionStore = sessionStore
    }

    // MARK: – Fetch

    func fetchSpots(filter: SpotFilter?) async throws -> [Spot] {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "select", value: "*")
        ]
        switch filter {
        case .topRated, .none:
            queryItems.append(URLQueryItem(name: "order", value: "rating.desc.nullslast"))
        case .hiddenGems:
            queryItems.append(URLQueryItem(name: "order",    value: "save_count.asc"))
            queryItems.append(URLQueryItem(name: "category", value: "eq.Hidden"))
        case .mostViewed:
            queryItems.append(URLQueryItem(name: "order", value: "view_count.desc.nullslast"))
        case .newlyFound:
            queryItems.append(URLQueryItem(name: "order", value: "created_at.desc"))
        }

        let request = APIRequest(
            method:       .get,
            path:         APIEndpoints.Spots.list,
            queryItems:   queryItems,
            requiresAuth: true
        )
        let dtos = try await apiClient.send(request, as: [SpotDTO].self)
        return dtos.map(SpotMapper.map)
    }

    func fetchFavorites() async throws -> [Spot] {
        let request = APIRequest(
            method:       .get,
            path:         APIEndpoints.Spots.list,
            queryItems:   [
                URLQueryItem(name: "select",      value: "*"),
                URLQueryItem(name: "is_favorite", value: "eq.true"),
                URLQueryItem(name: "order",       value: "rating.desc")
            ],
            requiresAuth: true
        )
        let dtos = try await apiClient.send(request, as: [SpotDTO].self)
        return dtos.map(SpotMapper.map)
    }

    func fetchNearbySpots() async throws -> [Spot] {
        // PostgREST doesn't support distance ordering natively without PostGIS RPC.
        // For now, return all spots ordered by rating. Real geo-query via RPC is next.
        let request = APIRequest(
            method:       .get,
            path:         APIEndpoints.Spots.list,
            queryItems:   [
                URLQueryItem(name: "select", value: "*"),
                URLQueryItem(name: "order",  value: "rating.desc")
            ],
            requiresAuth: true
        )
        let dtos = try await apiClient.send(request, as: [SpotDTO].self)
        return dtos.map(SpotMapper.map)
    }

    // MARK: – Mutations

    func toggleFavorite(spotID: UUID) async throws {
        guard let userID = await sessionStore.currentUserID else { throw APIError.unauthorized }

        // Check if already favorited then DELETE, otherwise INSERT
        let checkRequest = APIRequest(
            method:       .get,
            path:         APIEndpoints.Favorites.list,
            queryItems:   [
                URLQueryItem(name: "spot_id", value: "eq.\(spotID.uuidString)"),
                URLQueryItem(name: "user_id", value: "eq.\(userID.uuidString)"),
                URLQueryItem(name: "select",  value: "spot_id")
            ],
            requiresAuth: true
        )

        let existing = try await apiClient.send(checkRequest, as: [SpotIDDTO].self)

        if existing.isEmpty {
            // Add favorite
            let payload = FavoritePayload(userId: userID.uuidString, spotId: spotID.uuidString)
            let request = APIRequest(
                method:       .post,
                path:         APIEndpoints.Favorites.create,
                body:         try payload.asJSONData(),
                requiresAuth: true
            )
            try await apiClient.send(request)
        } else {
            // Remove favorite
            let request = APIRequest(
                method:       .delete,
                path:         APIEndpoints.Favorites.delete,
                queryItems:   [
                    URLQueryItem(name: "spot_id", value: "eq.\(spotID.uuidString)"),
                    URLQueryItem(name: "user_id", value: "eq.\(userID.uuidString)")
                ],
                requiresAuth: true
            )
            try await apiClient.send(request)
        }
    }

    func createSpot(_ draft: SpotDraft) async throws -> Spot {
        guard let userID = await sessionStore.currentUserID else { throw APIError.unauthorized }
        _ = userID

        let payload = CreateSpotPayload(
            name:        draft.name,
            location:    draft.location,
            description: draft.description,
            category:    draft.category.rawValue,
            imageUrl:    draft.imageURLs.first ?? "",
            latitude:    nil,
            longitude:   nil
        )
        var request = APIRequest(
            method:               .post,
            path:                 APIEndpoints.Spots.create,
            body:                 try payload.asJSONData(),
            requiresAuth:         true,
            preferRepresentation: true
        )
        request.headers["Content-Type"] = "application/json"

        let dto = try await apiClient.send(request, as: SpotDTO.self)
        return SpotMapper.map(dto)
    }
}

private struct SpotIDDTO: Decodable {
    let spotId: String
}
