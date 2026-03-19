import Foundation

private struct CreateSpotPayload: Encodable {
    let name:        String
    let location:    String
    let description: String
    let category:    String
    let imageUrl:    String
    let latitude:    Double?
    let longitude:   Double?
    let creatorId:   String
}

private struct FavoritePayload: Encodable {
    let userId: String
    let spotId: String
}

private struct NearbySpotsPayload: Encodable {
    let userLat: Double
    let userLon: Double
    let radiusMeters: Double
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

        queryItems.append(URLQueryItem(name: "limit", value: "50"))

        var request = APIRequest(
            method:       .get,
            path:         APIEndpoints.Spots.list,
            queryItems:   queryItems,
            requiresAuth: true
        )
        request.headers["Range-Unit"] = "items"
        request.headers["Range"] = "0-49"
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

    func fetchNearbySpots(latitude: Double, longitude: Double, radiusMeters: Double) async throws -> [Spot] {
        let payload = NearbySpotsPayload(
            userLat: latitude,
            userLon: longitude,
            radiusMeters: radiusMeters
        )
        let request = APIRequest(
            method:       .post,
            path:         APIEndpoints.Spots.nearbyRPC,
            body:         try payload.asJSONData(),
            requiresAuth: true
        )
        let dtos = try await apiClient.send(request, as: [SpotDTO].self)
        return dtos.map(SpotMapper.map)
    }

    // MARK: – Mutations

    func toggleFavorite(spotID: UUID) async throws {
        guard let userID = await sessionStore.currentUserID else { throw APIError.unauthorized }

        // Upsert with ON CONFLICT DO NOTHING (resolution=ignore-duplicates).
        // If Supabase returns an empty array, the row already existed → delete it.
        // This is a single round-trip that eliminates the TOCTOU race of GET-then-write.
        let payload = FavoritePayload(userId: userID.uuidString, spotId: spotID.uuidString)
        var insertRequest = APIRequest(
            method:               .post,
            path:                 APIEndpoints.Favorites.create,
            body:                 try payload.asJSONData(),
            requiresAuth:         true,
            preferRepresentation: true
        )
        insertRequest.headers["Prefer"] = "resolution=ignore-duplicates,return=representation"

        let inserted = try await apiClient.send(insertRequest, as: [SpotIDDTO].self)

        if inserted.isEmpty {
            // Row already existed and was not inserted → remove the favorite
            let deleteRequest = APIRequest(
                method:       .delete,
                path:         APIEndpoints.Favorites.delete,
                queryItems:   [
                    URLQueryItem(name: "spot_id", value: "eq.\(spotID.uuidString)"),
                    URLQueryItem(name: "user_id", value: "eq.\(userID.uuidString)")
                ],
                requiresAuth: true
            )
            try await apiClient.send(deleteRequest)
        }
    }

    func createSpot(_ draft: SpotDraft) async throws -> Spot {
        guard let userID = await sessionStore.currentUserID else { throw APIError.unauthorized }

        let payload = CreateSpotPayload(
            name:        draft.name,
            location:    draft.location,
            description: draft.description,
            category:    draft.category.rawValue,
            imageUrl:    draft.imageURLs.first ?? "",
            latitude:    draft.latitude,
            longitude:   draft.longitude,
            creatorId:   userID.uuidString
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

    func addPhotosToSpot(spotID: UUID, imageURLs: [String]) async throws {
        struct SpotPhotoPayload: Encodable {
            let spotId:   String
            let imageUrl: String
        }
        for url in imageURLs {
            let photoPayload = SpotPhotoPayload(spotId: spotID.uuidString, imageUrl: url)
            let request = APIRequest(
                method:       .post,
                path:         APIEndpoints.SpotPhotos.create,
                body:         try photoPayload.asJSONData(),
                requiresAuth: true
            )
            try await apiClient.send(request)
        }
    }

    func fetchSpotsByCreator(userId: UUID) async throws -> [Spot] {
        let request = APIRequest(
            method:       .get,
            path:         APIEndpoints.Spots.list,
            queryItems:   [
                URLQueryItem(name: "creator_id", value: "eq.\(userId.uuidString)"),
                URLQueryItem(name: "select",     value: "*"),
                URLQueryItem(name: "order",      value: "created_at.desc")
            ],
            requiresAuth: true
        )
        let dtos = try await apiClient.send(request, as: [SpotDTO].self)
        return dtos.map(SpotMapper.map)
    }
}

private struct SpotIDDTO: Decodable {
    let spotId: String
}
