import Foundation

protocol AuthRepositoryProtocol {
    func signIn(email: String, password: String) async throws -> User
    func signUp(email: String, password: String, username: String) async throws -> User
    func signInWithGoogle() async throws -> User
    func signOut() async throws
    func currentUser() async -> User?
}
