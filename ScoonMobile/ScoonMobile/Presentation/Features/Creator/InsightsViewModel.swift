import Foundation

enum InsightsPeriod: String, CaseIterable {
    case week    = "7 Tage"
    case month   = "30 Tage"
    case quarter = "90 Tage"
}

@Observable
@MainActor
final class InsightsViewModel {
    private(set) var summary:    InsightsSummary?
    private(set) var topSpots:   [Spot]   = []
    private(set) var isLoading:  Bool     = false
    private(set) var error:      String?

    var selectedPeriod: InsightsPeriod = .month

    private let fetchInsights: FetchInsightsUseCase
    private let fetchProfile:  FetchUserProfileUseCase

    init(fetchInsights: FetchInsightsUseCase, fetchProfile: FetchUserProfileUseCase) {
        self.fetchInsights = fetchInsights
        self.fetchProfile  = fetchProfile
    }

    func onAppear() async {
        guard summary == nil else { return }
        await load()
    }

    func selectPeriod(_ period: InsightsPeriod) {
        selectedPeriod = period
        summary = nil
        Task { await load() }
    }

    private func load() async {
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
