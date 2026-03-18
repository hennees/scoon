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

    init(fetchProfile: FetchUserProfileUseCase) {
        self.fetchProfile = fetchProfile
    }

    var displayedSpots: [Spot] {
        activeTab == .explored ? exploredSpots : savedSpots
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
