import Foundation

struct FetchUserProfileUseCase {
    private let repository: UserRepositoryProtocol

    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> (user: User, explored: [Spot], saved: [Spot]) {
        let user = try await repository.fetchCurrentUser()
        async let explored = repository.fetchExploredSpots(userID: user.id)
        async let saved    = repository.fetchSavedSpots(userID: user.id)
        return try await (user, explored, saved)
    }
}
