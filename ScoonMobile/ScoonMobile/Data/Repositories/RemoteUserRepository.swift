import Foundation

final class RemoteUserRepository: UserRepositoryProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func fetchCurrentUser() async throws -> User {
        let request = APIRequest(method: .get, path: APIEndpoints.Users.me, requiresAuth: true)
        let dto = try await apiClient.send(request, as: UserDTO.self)
        return UserMapper.map(dto)
    }

    func fetchExploredSpots(userID: UUID) async throws -> [Spot] {
        let request = APIRequest(
            method: .get,
            path: APIEndpoints.Users.exploredSpots(userID: userID),
            requiresAuth: true
        )

        let dtos = try await apiClient.send(request, as: [SpotDTO].self)
        return dtos.map(SpotMapper.map)
    }

    func fetchSavedSpots(userID: UUID) async throws -> [Spot] {
        let request = APIRequest(
            method: .get,
            path: APIEndpoints.Users.savedSpots(userID: userID),
            requiresAuth: true
        )

        let dtos = try await apiClient.send(request, as: [SpotDTO].self)
        return dtos.map(SpotMapper.map)
    }
}
