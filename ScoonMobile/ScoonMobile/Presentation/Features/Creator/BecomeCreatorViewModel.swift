import Foundation

@Observable
@MainActor
final class BecomeCreatorViewModel {
    private(set) var isLoading = false
    private(set) var isSuccess = false
    private(set) var error: String?

    private let userRepository: UserRepositoryProtocol

    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }

    func requestAccess() async {
        guard !isLoading else { return }
        isLoading = true
        error = nil
        do {
            let updated = try await userRepository.requestCreatorAccess()
            NotificationCenter.default.post(name: .profileUpdated, object: updated)
            isSuccess = true
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
