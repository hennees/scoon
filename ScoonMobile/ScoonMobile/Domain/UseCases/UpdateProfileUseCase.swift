import Foundation

struct UpdateProfileUseCase {
    private let repository: UserRepositoryProtocol

    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }

    func execute(userID: UUID, username: String, bio: String, avatarURL: String?) async throws -> User {
        let trimmedUsername = username.trimmingCharacters(in: .whitespaces)
        let trimmedBio      = bio.trimmingCharacters(in: .whitespaces)
        guard !trimmedUsername.isEmpty else {
            throw UpdateProfileError.emptyUsername
        }
        return try await repository.updateProfile(
            userID:    userID,
            username:  trimmedUsername,
            bio:       trimmedBio,
            avatarURL: avatarURL
        )
    }
}

enum UpdateProfileError: LocalizedError {
    case emptyUsername
    var errorDescription: String? {
        switch self {
        case .emptyUsername: return "Benutzername darf nicht leer sein."
        }
    }
}
