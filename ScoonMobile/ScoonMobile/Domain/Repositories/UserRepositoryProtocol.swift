import Foundation

protocol UserRepositoryProtocol {
    func fetchCurrentUser() async throws -> User
    func fetchExploredSpots(userID: UUID) async throws -> [Spot]
    func fetchSavedSpots(userID: UUID) async throws -> [Spot]
    func updateProfile(userID: UUID, username: String, bio: String, avatarURL: String?) async throws -> User
    func requestCreatorAccess() async throws -> User
}
