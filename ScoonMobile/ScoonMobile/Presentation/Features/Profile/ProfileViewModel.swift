import Foundation

@Observable
@MainActor
final class ProfileViewModel {
    private(set) var user:          User?    = nil
    private(set) var exploredSpots: [Spot]   = []
    private(set) var savedSpots:    [Spot]   = []
    private(set) var isLoading:     Bool     = false
    private(set) var error:         String?

    var activeTab: ProfileTab = .explored

    private let fetchProfile: FetchUserProfileUseCase
    private nonisolated(unsafe) var updateTask: Task<Void, Never>?

    init(fetchProfile: FetchUserProfileUseCase) {
        self.fetchProfile = fetchProfile
        startObservingProfileUpdates()
    }

    private func startObservingProfileUpdates() {
        updateTask = Task { [weak self] in
            for await notification in NotificationCenter.default.notifications(named: .profileUpdated) {
                guard let self, let updated = notification.object as? User else { continue }
                self.user = updated
            }
        }
    }

    deinit { updateTask?.cancel() }

    var displayedSpots: [Spot] {
        activeTab == .explored ? exploredSpots : savedSpots
    }

    func refresh() async {
        user = nil
        await onAppear()
    }

    func onAppear() async {
        guard user == nil else { return }
        isLoading = true
        error = nil
        do {
            let result  = try await fetchProfile.execute()
            user          = result.user
            exploredSpots = result.explored
            savedSpots    = result.saved
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}

enum ProfileTab { case explored, saved }
