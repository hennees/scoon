import Foundation

struct FetchMySpotsUseCase {
    private let repository:     SpotRepositoryProtocol
    private let authRepository: AuthRepositoryProtocol

    init(repository: SpotRepositoryProtocol, authRepository: AuthRepositoryProtocol) {
        self.repository     = repository
        self.authRepository = authRepository
    }

    func execute() async throws -> [Spot] {
        guard let user = await authRepository.currentUser() else { return [] }
        return try await repository.fetchSpotsByCreator(userId: user.id)
    }
}
