import Foundation

@Observable
final class InsightsViewModel {
    private(set) var summary:    InsightsSummary?
    private(set) var topSpots:   [Spot]   = []
    private(set) var isLoading:  Bool     = false
    private(set) var error:      String?

    private let fetchInsights: FetchInsightsUseCase
    private let fetchProfile:  FetchUserProfileUseCase

    init(fetchInsights: FetchInsightsUseCase, fetchProfile: FetchUserProfileUseCase) {
        self.fetchInsights = fetchInsights
        self.fetchProfile  = fetchProfile
    }

    func onAppear() async {
        guard summary == nil else { return }
        isLoading = true
        error = nil
        do {
            let userResult = try await fetchProfile.execute()
            let result     = try await fetchInsights.execute(userID: userResult.user.id)
            summary  = result.summary
            topSpots = result.topSpots
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
