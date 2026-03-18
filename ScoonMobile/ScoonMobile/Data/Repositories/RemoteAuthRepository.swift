import Foundation
import AuthenticationServices

// MARK: – Supabase Auth response DTOs

private struct SupabaseSessionDTO: Decodable {
    let accessToken:  String
    let refreshToken: String
    let user:         SupabaseUserDTO
}

private struct SupabaseUserDTO: Decodable {
    let id:           String
    let email:        String?
    let userMetadata: UserMetaDTO?
}

private struct UserMetaDTO: Decodable {
    let username:  String?
    let fullName:  String?  // Google provides this
    let avatarUrl: String?  // Google provides this
}

// MARK: – RemoteAuthRepository

final class RemoteAuthRepository: AuthRepositoryProtocol {
    private let apiClient:    APIClientProtocol
    private let sessionStore: AuthSessionStore
    private let supabaseURL:  String

    init(apiClient: APIClientProtocol, sessionStore: AuthSessionStore, supabaseURL: String) {
        self.apiClient    = apiClient
        self.sessionStore = sessionStore
        self.supabaseURL  = supabaseURL
    }

    // MARK: – Email / Password

    func signIn(email: String, password: String) async throws -> User {
        let body = try ["email": email, "password": password].asJSONData()
        let request = APIRequest(
            method:     .post,
            path:       APIEndpoints.Auth.signIn,
            queryItems: [URLQueryItem(name: "grant_type", value: "password")],
            body:       body
        )
        do {
            let session = try await apiClient.send(request, as: SupabaseSessionDTO.self)
            return try await handleSession(session)
        } catch {
            throw mapAuthError(error)
        }
    }

    func signUp(email: String, password: String, username: String) async throws -> User {
        let payload: [String: Any] = [
            "email":    email,
            "password": password,
            "data":     ["username": username]
        ]
        let body = try JSONSerialization.data(withJSONObject: payload)
        let request = APIRequest(method: .post, path: APIEndpoints.Auth.signUp, body: body)
        do {
            let session = try await apiClient.send(request, as: SupabaseSessionDTO.self)
            return try await handleSession(session)
        } catch {
            throw mapAuthError(error)
        }
    }

    // MARK: – Google OAuth (ASWebAuthenticationSession)

    func signInWithGoogle() async throws -> User {
        let callbackScheme = "scoon"
        let callbackURL    = "\(callbackScheme)://auth/callback"
        let urlString      = "\(supabaseURL)/auth/v1/authorize?provider=google&redirect_to=\(callbackURL)"

        guard let url = URL(string: urlString) else { throw APIError.invalidRequest }

        let fragment: String = try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(url: url, callbackURLScheme: callbackScheme) { cbURL, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let fragment = cbURL?.fragment, !fragment.isEmpty else {
                    continuation.resume(throwing: APIError.decodingFailed)
                    return
                }
                continuation.resume(returning: fragment)
            }
            session.presentationContextProvider = WebAuthContext.shared
            session.prefersEphemeralWebBrowserSession = true  // always show account picker
            session.start()
        }

        // Parse fragment: access_token=...&refresh_token=...&...
        let params = fragment.components(separatedBy: "&").reduce(into: [String: String]()) { d, pair in
            let parts = pair.components(separatedBy: "=")
            if parts.count == 2 { d[parts[0]] = parts[1].removingPercentEncoding ?? parts[1] }
        }
        guard let accessToken  = params["access_token"],
              let refreshToken = params["refresh_token"] else {
            throw APIError.decodingFailed
        }

        // Fetch the user with the new token
        let tempStore = sessionStore
        await tempStore.setSession(accessToken: accessToken, refreshToken: refreshToken, userID: UUID())

        let userRequest = APIRequest(method: .get, path: APIEndpoints.Auth.currentUser, requiresAuth: true)
        let supabaseUser = try await apiClient.send(userRequest, as: SupabaseUserDTO.self)
        guard let userID = UUID(uuidString: supabaseUser.id) else { throw APIError.decodingFailed }
        await sessionStore.setSession(accessToken: accessToken, refreshToken: refreshToken, userID: userID)

        return User(
            id:             userID,
            username:       supabaseUser.userMetadata?.fullName
                            ?? supabaseUser.userMetadata?.username
                            ?? supabaseUser.email.flatMap { $0.components(separatedBy: "@").first }
                            ?? "User",
            email:          supabaseUser.email ?? "",
            bio:            "",
            avatarURL:      supabaseUser.userMetadata?.avatarUrl ?? "",
            postCount:      0,
            followerCount:  0,
            followingCount: 0
        )
    }

    // MARK: – Session Management

    func signOut() async throws {
        let request = APIRequest(method: .post, path: APIEndpoints.Auth.signOut, requiresAuth: true)
        do {
            try await apiClient.send(request)
            await sessionStore.clear()
        } catch {
            await sessionStore.clear() // clear locally even if server call fails
            throw mapAuthError(error)
        }
    }

    func currentUser() async -> User? {
        let request = APIRequest(method: .get, path: APIEndpoints.Auth.currentUser, requiresAuth: true)
        guard let dto = try? await apiClient.send(request, as: SupabaseUserDTO.self),
              let userID = UUID(uuidString: dto.id) else { return nil }
        return User(
            id: userID,
            username: dto.userMetadata?.username ?? dto.email?.components(separatedBy: "@").first ?? "User",
            email:    dto.email ?? "",
            bio: "", avatarURL: dto.userMetadata?.avatarUrl ?? "",
            postCount: 0, followerCount: 0, followingCount: 0
        )
    }

    // MARK: – Private

    private func handleSession(_ session: SupabaseSessionDTO) async throws -> User {
        guard let userID = UUID(uuidString: session.user.id) else { throw APIError.decodingFailed }
        await sessionStore.setSession(
            accessToken:  session.accessToken,
            refreshToken: session.refreshToken,
            userID:       userID
        )
        return User(
            id:             userID,
            username:       session.user.userMetadata?.username
                            ?? session.user.email?.components(separatedBy: "@").first
                            ?? "User",
            email:          session.user.email ?? "",
            bio:            "",
            avatarURL:      session.user.userMetadata?.avatarUrl ?? "",
            postCount:      0,
            followerCount:  0,
            followingCount: 0
        )
    }

    private func mapAuthError(_ error: Error) -> Error {
        guard let apiError = error as? APIError else { return error }
        switch apiError {
        case .unauthorized:        return AuthError.wrongPassword
        case .conflict:            return AuthError.emailAlreadyInUse
        case .unprocessableEntity: return AuthError.invalidEmail
        case .forbidden:           return AuthError.emailNotConfirmed
        default:                   return apiError
        }
    }
}

// MARK: – ASWebAuthenticationSession presentation context

private final class WebAuthContext: NSObject, ASWebAuthenticationPresentationContextProviding {
    static let shared = WebAuthContext()
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.keyWindow ?? ASPresentationAnchor()
    }
}

// MARK: – Dictionary JSON helper

private extension Dictionary where Key == String, Value == String {
    func asJSONData() throws -> Data {
        try JSONSerialization.data(withJSONObject: self)
    }
}
