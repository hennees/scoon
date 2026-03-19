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
        struct ProfileUpdatePayload: Encodable {
            let username:  String
            let bio:       String
            let avatarUrl: String?
        }
        let payload = ProfileUpdatePayload(username: username, bio: bio, avatarUrl: avatarURL)
        let request = APIRequest(
            method:               .patch,
            path:                 APIEndpoints.Users.me,
            queryItems:           [URLQueryItem(name: "id", value: "eq.\(userID.uuidString)")],
            body:                 try payload.asJSONData(),
            requiresAuth:         true,
            preferRepresentation: true
        )
        let dtos = try await apiClient.send(request, as: [UserDTO].self)
        guard let dto = dtos.first else { throw APIError.notFound }
        return UserMapper.map(dto)
    }

    func requestCreatorAccess() async throws -> User {
        guard let userID = await sessionStore.currentUserID else { throw APIError.unauthorized }
        struct CreatorUpdate: Encodable { let isCreator: Bool }
        let payload = CreatorUpdate(isCreator: true)
        let request = APIRequest(
            method:               .patch,
            path:                 APIEndpoints.Users.me,
            queryItems:           [URLQueryItem(name: "id", value: "eq.\(userID.uuidString)")],
            body:                 try payload.asJSONData(),
            requiresAuth:         true,
            preferRepresentation: true
        )
        let dtos = try await apiClient.send(request, as: [UserDTO].self)
        guard let dto = dtos.first else { throw APIError.notFound }
        return UserMapper.map(dto)
    }
}
