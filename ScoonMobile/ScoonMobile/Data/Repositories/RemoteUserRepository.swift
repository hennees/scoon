import Foundation

final class RemoteUserRepository: UserRepositoryProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func fetchCurrentUser() async throws -> User {
        let request = APIRequest(
            method: .get,
            path: APIEndpoints.Users.me,
            queryItems: [URLQueryItem(name: "select", value: "*")],
            requiresAuth: true
        )
        let dtos = try await apiClient.send(request, as: [UserDTO].self)
        guard let dto = dtos.first else { throw APIError.notFound }
        return UserMapper.map(dto)
    }

    func fetchExploredSpots(userID: UUID) async throws -> [Spot] {
        // Supabase: spots created by this user
        let request = APIRequest(
            method: .get,
            path: APIEndpoints.Spots.list,
            queryItems: [
                URLQueryItem(name: "select",     value: "*"),
                URLQueryItem(name: "creator_id", value: "eq.\(userID.uuidString)")
            ],
            requiresAuth: true
        )
        let dtos = try await apiClient.send(request, as: [SpotDTO].self)
        return dtos.map(SpotMapper.map)
    }

    func fetchSavedSpots(userID: UUID) async throws -> [Spot] {
        // Supabase: spots favorited by this user
        let request = APIRequest(
            method: .get,
            path: APIEndpoints.Spots.list,
            queryItems: [
                URLQueryItem(name: "select",      value: "*"),
                URLQueryItem(name: "is_favorite", value: "eq.true")
            ],
            requiresAuth: true
        )
        let dtos = try await apiClient.send(request, as: [SpotDTO].self)
        return dtos.map(SpotMapper.map)
    }
}
