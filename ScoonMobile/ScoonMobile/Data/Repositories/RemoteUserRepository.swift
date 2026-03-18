import Foundation

final class RemoteUserRepository: UserRepositoryProtocol {
    private let apiClient:    APIClientProtocol
    private let sessionStore: AuthSessionStore

    init(apiClient: APIClientProtocol, sessionStore: AuthSessionStore) {
        self.apiClient    = apiClient
        self.sessionStore = sessionStore
    }

    func fetchCurrentUser() async throws -> User {
        guard let userID = await sessionStore.currentUserID else { throw APIError.unauthorized }
        let request = APIRequest(
            method: .get,
            path: APIEndpoints.Users.me,
            queryItems: [
                URLQueryItem(name: "id",     value: "eq.\(userID.uuidString)"),
                URLQueryItem(name: "select", value: "*")
            ],
            requiresAuth: true
        )
        let dtos = try await apiClient.send(request, as: [UserDTO].self)
        guard let dto = dtos.first else { throw APIError.notFound }
        return UserMapper.map(dto)
    }

    func fetchExploredSpots(userID: UUID) async throws -> [Spot] {
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

    func updateProfile(userID: UUID, username: String, bio: String, avatarURL: String?) async throws -> User {
        // Stub: PATCH /users when backend supports profile editing
        throw APIError.serverError(statusCode: 501)
    }

    func requestCreatorAccess() async throws -> User {
        // Stub: POST /creator-requests when backend supports creator applications
        throw APIError.serverError(statusCode: 501)
    }
}
