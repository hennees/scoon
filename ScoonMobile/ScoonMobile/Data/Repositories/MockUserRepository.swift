import Foundation

final class MockUserRepository: UserRepositoryProtocol {

    var simulatedDelay: Double = 0.3

    private var currentUser = User(
        id:             UUID(),
        username:       "Patrick Hennes",
        email:          "patrick.hennes@scoon.at",
        bio:            "Fotograf & Entdecker aus Graz. Immer auf der Suche nach dem perfekten Spot.",
        avatarURL:      "https://www.figma.com/api/mcp/asset/4c92510c-b715-4ba9-b560-fb389c098aad",
        postCount:      12,
        followerCount:  612,
        followingCount: 124,
        isCreator:      false
    )

    func fetchCurrentUser() async throws -> User {
        try await Task.sleep(for: .seconds(simulatedDelay))
        return currentUser
    }

    func fetchExploredSpots(userID: UUID) async throws -> [Spot] {
        try await Task.sleep(for: .seconds(simulatedDelay))
        let repo = MockSpotRepository()
        repo.simulatedDelay = 0
        return try await repo.fetchSpots(filter: nil)
    }

    func fetchSavedSpots(userID: UUID) async throws -> [Spot] {
        try await Task.sleep(for: .seconds(simulatedDelay))
        let repo = MockSpotRepository()
        repo.simulatedDelay = 0
        return try await repo.fetchFavorites()
    }

    func updateProfile(userID: UUID, username: String, bio: String, avatarURL: String?) async throws -> User {
        try await Task.sleep(for: .seconds(simulatedDelay))
        currentUser = User(
            id:             currentUser.id,
            username:       username,
            email:          currentUser.email,
            bio:            bio,
            avatarURL:      avatarURL ?? currentUser.avatarURL,
            postCount:      currentUser.postCount,
            followerCount:  currentUser.followerCount,
            followingCount: currentUser.followingCount,
            isCreator:      currentUser.isCreator
        )
        return currentUser
    }

    func requestCreatorAccess() async throws -> User {
        try await Task.sleep(for: .seconds(simulatedDelay))
        currentUser = User(
            id:             currentUser.id,
            username:       currentUser.username,
            email:          currentUser.email,
            bio:            currentUser.bio,
            avatarURL:      currentUser.avatarURL,
            postCount:      currentUser.postCount,
            followerCount:  currentUser.followerCount,
            followingCount: currentUser.followingCount,
            isCreator:      true
        )
        return currentUser
    }
}
