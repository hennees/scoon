import Foundation

enum AuthError: LocalizedError {
    case invalidEmail
    case wrongPassword
    case userNotFound
    case emailAlreadyInUse
    case weakPassword
    case emailNotConfirmed

    var errorDescription: String? {
        switch self {
        case .invalidEmail:      return "Bitte gib eine gültige E-Mail-Adresse ein."
        case .wrongPassword:     return "Falsches Passwort. Bitte versuche es erneut."
        case .userNotFound:      return "Kein Konto mit dieser E-Mail gefunden."
        case .emailAlreadyInUse: return "Diese E-Mail-Adresse wird bereits verwendet."
        case .weakPassword:      return "Das Passwort muss mindestens 8 Zeichen lang sein."
        case .emailNotConfirmed: return "Bitte bestätige zuerst deine E-Mail-Adresse. Schau in dein Postfach."
        }
    }
}

final class MockAuthRepository: AuthRepositoryProtocol {

    private let mockUser = User(
        id:             UUID(),
        username:       "Patrick Hennes",
        email:          "patrick@scoon.at",
        bio:            "Fotograf & Entdecker aus Graz.",
        avatarURL:      "",
        postCount:      12,
        followerCount:  612,
        followingCount: 124,
        isCreator:      false
    )

    func signIn(email: String, password: String) async throws -> User {
        try await Task.sleep(for: .seconds(1.2))
        guard email.contains("@") else { throw AuthError.invalidEmail }
        guard password.count >= 6  else { throw AuthError.wrongPassword }
        return mockUser
    }

    func signUp(email: String, password: String, username: String) async throws -> User {
        try await Task.sleep(for: .seconds(1.5))
        guard email.contains("@")  else { throw AuthError.invalidEmail }
        guard password.count >= 8  else { throw AuthError.weakPassword }
        guard !username.isEmpty    else { throw AuthError.userNotFound }
        return User(
            id: UUID(), username: username, email: email,
            bio: "", avatarURL: "",
            postCount: 0, followerCount: 0, followingCount: 0,
            isCreator: false
        )
    }

    func signInWithGoogle() async throws -> User {
        try await Task.sleep(for: .seconds(0.8))
        return User(
            id: UUID(), username: "Google User", email: "user@gmail.com",
            bio: "", avatarURL: "",
            postCount: 0, followerCount: 0, followingCount: 0,
            isCreator: false
        )
    }

    func signOut() async throws {
        try await Task.sleep(for: .seconds(0.3))
    }

    func currentUser() async -> User? { nil }
}
