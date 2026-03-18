import Foundation

@Observable
@MainActor
final class AuthViewModel {
    var email:    String = ""
    var password: String = ""
    var username: String = ""

    private(set) var isLoading:      Bool    = false
    private(set) var error:          String? = nil
    private(set) var isSuccess:      Bool    = false
    private(set) var isSignedOut:    Bool    = false
    private(set) var resetEmailSent: Bool    = false
    var resetEmail: String = ""

    private let authRepository: AuthRepositoryProtocol

    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }

    // MARK: – Validation

    var isLoginValid: Bool {
        email.contains("@") && password.count >= 6
    }

    var isSignUpValid: Bool {
        email.contains("@") && password.count >= 8 && !username.isEmpty
    }

    // MARK: – Actions

    func login() async {
        guard isLoginValid else {
            error = "Bitte gib eine gültige E-Mail und ein Passwort (mind. 6 Zeichen) ein."
            return
        }
        await perform { try await self.authRepository.signIn(email: self.email, password: self.password) }
    }

    func signUp() async {
        guard isSignUpValid else {
            error = "Bitte fülle alle Felder aus (Passwort mind. 8 Zeichen)."
            return
        }
        await perform { try await self.authRepository.signUp(email: self.email, password: self.password, username: self.username) }
    }

    func signInWithGoogle() async {
        await perform { try await self.authRepository.signInWithGoogle() }
    }

    func signOut() async {
        isLoading = true
        error = nil
        do {
            try await authRepository.signOut()
            isSuccess = false
            isSignedOut = true
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func clearError() { error = nil }

    func resetPassword() async {
        guard resetEmail.contains("@") else {
            error = "Bitte gib eine gültige E-Mail-Adresse ein."
            return
        }
        isLoading = true
        error = nil
        do {
            try await authRepository.resetPassword(email: resetEmail)
            resetEmailSent = true
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func clearResetState() {
        resetEmailSent = false
        resetEmail = ""
        error = nil
    }

    // MARK: – Private

    private func perform(_ action: @escaping () async throws -> User) async {
        isLoading = true
        error     = nil
        do {
            _ = try await action()
            isSuccess = true
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
